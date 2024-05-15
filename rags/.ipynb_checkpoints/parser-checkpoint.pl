parse_input(Input, Commands, Attributes) :-
    % the parser will try to parse the input, 
    % at the end, Commands and Attributes should be unified ("assigned") with:
    %   - the AutoML symbols sequence   (Commands)
    %   - the list of elements that are to be fed to each operation (Attributes)
    phrase(parse(Commands, Attributes), Input).



parse(Commands, Attributes) -->
    task_type(TaskType), % the input always starts with the task type
    task_rules(TaskType, Commands, Attributes). % then followed by rules (extracted semantics)

%The task can be clustering or regression
task_type(regression) --> [regression].
task_type(clustering) --> [clustering].

%We will handle the extracted semantics depending on the task type
task_rules(regression, Commands, Attributes) -->
    regression_attributes(Commands, Attributes).

task_rules(clustering, Commands, Attributes) -->
    clustering_attributes(Commands, Attributes).


regression_attributes(Cmds, Attrs) -->
    attributes_section(Dependent, Independent), %regression tasks contain an attributes section with the dependent and independent attributes
    { process_regression_attributes(Dependent, Independent, Cmds, Attrs) }. % if parsed, the Commands and Attributes will be parsed


clustering_attributes(Cmds, Attrs) -->
    [attributes], attributes(ClusterAttributes), %clustering tasks contain an attributes section with the clustering attributes
    { process_clustering_attributes(ClusterAttributes, Cmds, Attrs) }.  % if parsed, the Commands and Attributes will be parsed

attributes_section(Dependent, Independent) --> % matches the output format of the LLM
    [dependent, attribute], attribute(Dependent),  % first dependent attribute
    [independent, attributes], attributes(Independent). % list of independent attributes

% Parse a single attribute
attribute(Attr) --> [Attr], {is_attribute(Attr) }.

% Parse a list of attributes
attributes([Attr|Attrs]) --> attribute(Attr), attributes(Attrs).
attributes([]) --> [].

% Possible attributes
is_attribute(Attr) :- memberchk(Attr, [id, surface, mass, height, volume, density]).
% Possible complex attributes
is_complex(Attr) :- memberchk(Attr, [volume, density]).

% List is a list of attributes and ComplexElements will be unified with a sublist of the first one containing only the complex attributes
find_complex_elements(List, ComplexElements) :-
    findall(Elem, (member(Elem, List), is_complex(Elem)), ComplexElements).

% hulp predicates to extract the first and second element of a list of 2 elements
first_element([X,_], X).
second_element([_,Y], Y).

%The AutoML commands and needed elements to calculate our complex attributes
calculate_command_attrs(volume, [calculateVolume, [surfaceInSquareMeters, heightInMeters]]).
calculate_command_attrs(density, [calculateDensity, [massInKilograms, surfaceInSquareMeters]]).

% ComplexAttributes is a list of complex attributes, CommandsAttributes will be unified with a list of the corresponding needed information (AutoML commands and needed elements)

find_commands_and_attributes(ComplexAttributes, CommandsAttributes) :-
    maplist(calculate_command_attrs, ComplexAttributes, CommandsAttributes).

process_regression_attributes(
    Dependent,
    Independent,
    [loadData, splitTrainTestData, knnRegression, regressionMSEError],  % Commands
    [[], [], [Independent, Dependent], knnRegression_OUTPUT]) :- % Attributes for the commands
    find_complex_elements(Independent, []), % In case of no complex attribute
    \+ is_complex(Dependent). % In case of no complex attribute

% In case of one or more complex attribute
process_regression_attributes(
    Dependent,
    Independent,
    FinalCommands,
    FinalAttributes) :-

    append([Dependent], Independent, Attributes), %all attributes in one list
    find_complex_elements(Attributes, ComplexAttributes),% find complex elements
    find_commands_and_attributes(ComplexAttributes, CalculateCommandsAttributes), % find correspondiong AutoML commands and needed elements for each complex attribute

    maplist(first_element, CalculateCommandsAttributes, CalculateCommands), % all commands
    maplist(second_element, CalculateCommandsAttributes, CalculateAttributes), % all corresponding attributes for the commands

    %append the final result (Commands)
    append([loadData], CalculateCommands, BeginCommands), 
    append(BeginCommands, [splitTrainTestData, knnRegression, regressionMSEError], FinalCommands),

    %append the final result (Attributes)
    append([[]], CalculateAttributes, BeginAttributes),
    append(BeginAttributes, [[], [Independent, Dependent], knnRegression_OUTPUT], FinalAttributes). 

process_clustering_attributes(
    Attributes, %Cluster Attributes
    [loadData, clusterData, clusterCount], % Commands
    [[], Attributes, clusterData_OUTPUT]) :- % Attributes for the commands
    find_complex_elements(Attributes, []). %In case of no complex attribute



process_clustering_attributes(
    Attributes, 
    FinalCommands,
    FinalAttributes) :-

    
    find_complex_elements(Attributes, ComplexAttributes), % find complex elements
    find_commands_and_attributes(ComplexAttributes, CalculateCommandsAttributes), % find correspondiong AutoML commands and needed elements for each complex attribute

    maplist(first_element, CalculateCommandsAttributes, CalculateCommands), % all commands
    maplist(second_element, CalculateCommandsAttributes, CalculateAttributes),% all corresponding attributes for the commands

    %append the final result (Commands)

    append([loadData], CalculateCommands, BeginCommands),
    append(BeginCommands, [clusterData, clusterCount], FinalCommands),

    %append the final result (Attributes)

    append([[]], CalculateAttributes, BeginAttributes),
    append(BeginAttributes, [Attributes, clusterData_OUTPUT], FinalAttributes). 
    