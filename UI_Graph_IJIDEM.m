classdef UI_Graph_IJIDEM < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        CommandpanelPanel           matlab.ui.container.Panel
        GridLayout7                 matlab.ui.container.GridLayout
        InputCheckBox               matlab.ui.control.CheckBox
        OutputCheckBox              matlab.ui.control.CheckBox
        LayoutButtonGroup           matlab.ui.container.ButtonGroup
        CircleButton                matlab.ui.control.RadioButton
        AutomaticButton             matlab.ui.control.RadioButton
        SelectoperationButtonGroup  matlab.ui.container.ButtonGroup
        connectionButton            matlab.ui.control.RadioButton
        extractionButton            matlab.ui.control.RadioButton
        LoadDataButton              matlab.ui.control.Button
        GridLayout10                matlab.ui.container.GridLayout
        ResetButton                 matlab.ui.control.Button
        UpdateButton                matlab.ui.control.Button
        ElementsPanel               matlab.ui.container.Panel
        GridLayout2                 matlab.ui.container.GridLayout
        TabGroup                    matlab.ui.container.TabGroup
        GraphTab                    matlab.ui.container.Tab
        GridLayout_2                matlab.ui.container.GridLayout
        UIAxes                      matlab.ui.control.UIAxes
        AdjacencyMatrixTab          matlab.ui.container.Tab
        GridLayout5                 matlab.ui.container.GridLayout
        UITable                     matlab.ui.control.Table
        WorkflowTab                 matlab.ui.container.Tab
        LevelsDropDown              matlab.ui.control.DropDown
        LevelsDropDownLabel         matlab.ui.control.Label
        ListBox                     matlab.ui.control.ListBox
        ListBoxLabel                matlab.ui.control.Label
        Panel                       matlab.ui.container.Panel
        ElementsDropDown            matlab.ui.control.DropDown
        ElementsDropDownLabel       matlab.ui.control.Label
        DeleteelementButton         matlab.ui.control.Button
        AddelementButton            matlab.ui.control.Button
        UIAxes2                     matlab.ui.control.UIAxes
        ContextMenu                 matlab.ui.container.ContextMenu
        MoveMenu                    matlab.ui.container.Menu
    end

    
    properties (Access = private)
        RawData % initial data from file
        RawGraph
    end
    
    methods (Access = private)
        
        % evidenzia le colonne selezionate
        function HighlightForCheckBox(app, src, event)  % src rappresenta la casella della checkbox
            value = src.Value;      % faccio un assegnazione
            % forzo il nome della colonna ad essere una stringa
            col = find(string(app.UITable.ColumnName) == src.Text);
            if value == 1           % se la checkbox è selezionata
                s1 = uistyle;                       % Create style for table UI component
                s1.BackgroundColor = 'cyan';        % assegna al background un colore
                % cerca l'indice della colonna in cui c'è il testo che voglio
                addStyle(app.UITable,s1,'column', col); % modifico lo stile della colonna 
                addStyle(app.UITable,s1,'row', col);
            else                    % quando si deseleziona la checkbox
                rowStyle = cell2mat(app.UITable.StyleConfigurations.TargetIndex);
                removeStyle(app.UITable, find(rowStyle==col));
            end
        end
        
        function HighlightForCheckBox2(app, src, event)
            removeStyle(app.UITable)
            value = src.Value;      % faccio un assegnazione
            % forzo il nome della colonna ad essere una stringa
            col = find(string(app.UITable.ColumnName) == src.Text);
            if value == 1           % se la checkbox è selezionata
                s1 = uistyle;                       % Create style for table UI component
                s1.BackgroundColor = 'cyan';        % assegna al background un colore
                % cerca l'indice della colonna in cui c'è il testo che voglio
                addStyle(app.UITable,s1,'column', col); % modifico lo stile della colonna 
                addStyle(app.UITable,s1,'row', col);
                for i=1:length(app.GridLayout2.Children)
                    if (string(app.GridLayout2.Children(i).Text)~=string(src.Text))
                        app.GridLayout2.Children(i).Value=0;
                    end
                end
            end
        end
        
        function plot_digraph(app,A,B)
            G = digraph(A,B,'omitselfloops');
            C = condensation(G);
            p = plot(app.UIAxes,G);
%             p = plot(app.UIAxes,G,'ButtonDownFcn',@(f,~)edit_graph(f,p));
%             plot(app.UIAxes,G,'ButtonDownFcn',@mouse_click);
            cc = conncomp(G);     % componenti fortemente connesse       
            p.NodeCData=cc;     % evidenzio i nodi appartenenti alle componenti
            p.LineWidth=2;
            p.MarkerSize=8;
            p.NodeFontSize=10;
            p.NodeFontWeight='bold';
            app.RawGraph.p=p;
%             layout(p,'circle')
%             layout(p,'auto')
%             set(ax,'WindowButtonDownFcn',@(f,~)edit_graph(f,p));
%             set(app.UIAxes,'ButtonDownFcn',@(f,~)edit_graph(f,app.UIAxes));
%         end

            function edit_graph(app,f,h)
        
                % Figure out which node is closest to the mouse. 
                a = ancestor(h,'axes');
                pt = a.CurrentPoint(1,1:2);
                dx = h.Data - pt(1);
                dy = h.Data - pt(2);
                len = sqrt(dx.^2 + dy.^2);
                [lmin,idx] = min(len);
                
                % If we're too far from a node, just return
                tol = max(diff(a.XLim),diff(a.YLim))/20;    
                if lmin > tol || isempty(idx)
                    return
                end
                node = idx(1);
    
                % Install new callbacks on figure
                f.ButtonMotionFcn = @motion_fcn;
                f.ButtonUpFcn = @release_fcn;
            
                % A ButtonMotionFcn that changes XData & YData
                function motion_fcn(~,~)
                    newx = a.CurrentPoint(1,1);
                    newy = a.CurrentPoint(1,2);
                    h.Data(node) = newx;
                    h.Data(node) = newy;
                    drawnow;
                end
    
                % A ButtonUpFcn which stops dragging
                function release_fcn(~,~)
                    f.ButtonMotionFcn = [];
                    f.ButtonUpFcn = [];
                end
            end
        end

%         function mouse_click(~,eventData)
%             % get coordinates of click 
%             coords = eventData.IntersectionPoint;
%             % do something with the coordinates (e.g. add coordinates to table)
%             app.UITable.Data(end+1,:) = [coords(1),coords(2)];
%         end

    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.SelectoperationButtonGroup.Buttons(1, 1).Enable = 0;
            app.SelectoperationButtonGroup.Buttons(1, 2).Enable = 0;
            app.InputCheckBox.Enable = 0;
            app.OutputCheckBox.Enable = 0;
            app.InputCheckBox.Value = 1;
        end

        % Button pushed function: LoadDataButton
        function LoadDataButtonPushed(app, event)
            [file,path] = uigetfile({'*.csv'; '*.CSV'}, 'Load CSV file');    % apre finestra di dialogo fitra file
            figure(app.UIFigure);       % torna sulla schermata dell'app
            
            if isequal(file,0)
                isLoaded = false;
            else
                fname = fullfile(path,file);
                isLoaded = true;
                
                opts = detectImportOptions(fname);      % rileva i dati da un file CSV
                tableData = readtable(fname, opts);
                fields = (opts.VariableNames)';
            end
            
            % CREA LE CASELLE DELLA CHECKBOX
            if isLoaded == true                                 % se caricato fai questo
                delete(app.GridLayout2.Children)    % elimina le checkbox precedenti
            
                app.UITable.Data = {};      % crea una tabella dai dati del file importato
                % set column names checkbox
                for i = 1:length(fields)                          
                    app.UITable.ColumnName(i) = fields(i);      % definisce i nomi delle colonne nella tabella
                    app.UITable.RowName(i) = fields(i);         % definisce i nomi delle righe nella tabella
                    % checkbox geneation
                    CheckBox = uicheckbox(app.GridLayout2);     % assegna le checkbox al gridlayout (caselle di selezione)
                    r = floor(i/(length(fields)/2+1));
                    CheckBox.Layout.Column = r + 1;                % stabilisce se la riga (diventa colonna) è la prima o la seconda
                    if r == 0
                        CheckBox.Layout.Row = i;             % elementi della prima riga
                    else
                        CheckBox.Layout.Row = i - floor(length(fields)/2);         % elementi della seconda riga
                    end
                    CheckBox.Text = fields(i);                  % assegna alle checkbox i nomi dei campi
                    CheckBox.FontSize=14;
                    % assegna la funzione HighlightColumnForCheckBox al
                    % gruppo della checkbox all'interno della sua struttura
                    CheckBox.ValueChangedFcn = @app.HighlightForCheckBox;     
                end
                %populate table data
                tableData.Properties.RowNames = fields;
                app.UITable.Data = tableData; % assegna all'elemento UITable le informazioni di tableData lette dal file importanto
                app.RawData = tableData;      % assegna ai dati non elaborati le informazioni di tableData
            end    

            plot_digraph(app,app.RawData.Variables,...
                app.RawData.Properties.VariableNames);
            app.SelectoperationButtonGroup.Buttons(1, 1).Enable = 1;
            app.SelectoperationButtonGroup.Buttons(1, 2).Enable = 1;
            
        end

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            if (app.extractionButton.Value == 1) 
                Nodi = cell2mat(app.UITable.StyleConfigurations.TargetIndex);
                Nodi = unique(Nodi);
                fields_2 = app.RawData.Properties.VariableNames(Nodi);
                Mat = app.RawData.Variables;
                Mat = Mat(Nodi,Nodi);
                plot_digraph(app,Mat,fields_2);
                j=1;
                for i = 1:length(app.GridLayout2.Children)
                    if  app.GridLayout2.Children(i).Value==1;
                        contatore1(j)=i;
                        j=j+1;
                    end
                end
                app.UITable.Data=app.UITable.Data(contatore1,contatore1);
                app.UITable.RowName=app.UITable.RowName(contatore1);
                app.UITable.ColumnName=app.UITable.ColumnName(contatore1);
                removeStyle(app.UITable)
            else
                for i = 1:length(app.GridLayout2.Children)
                    if (app.GridLayout2.Children(i).Value == 1)
%                         f = app.GridLayout2.Children(i).Text;
                        n = i;
                    end
                end
                f=app.RawData.Properties.VariableNames;
                m=app.RawData.Variables;
                if (app.InputCheckBox.Value == 1 && app.OutputCheckBox.Value == 1)
                    b=find(m(:,n)==1);
                    c=find(m(n,:)==1);
                    a=[b;c'];
                elseif (app.InputCheckBox.Value == 1)
                    a=find(m(:,n)==1);
                elseif (app.OutputCheckBox.Value == 1)
                    a=find(m(n,:)==1);
                else
                    return
                end
                a(end+1)=n;
                a=unique(a);
                f=f(a);
                m=m(a,a);
                plot_digraph(app,m,f);
            end
            app.AutomaticButton.Value = 1;
            for i = 1:length(app.GridLayout2.Children)
                app.GridLayout2.Children(i).Value = 0;
            end
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
                removeStyle(app.UITable)    % rimuove l'evidenziatore di righe e colonne
                for i = 1:length(app.GridLayout2.Children)
                    app.GridLayout2.Children(i).Value = 0;
                end
                plot_digraph(app,app.RawData.Variables,...
                    app.RawData.Properties.VariableNames);
                app.AutomaticButton.Value = 1;
                app.UITable.Data=app.RawData;
                app.UITable.RowName=app.RawData.Properties.VariableNames;
                app.UITable.ColumnName=app.RawData.Properties.VariableNames;
                removeStyle(app.UITable)
        end

        % Selection changed function: SelectoperationButtonGroup
        function SelectoperationButtonGroupSelectionChanged(app, event)
            selectedButton = app.SelectoperationButtonGroup.SelectedObject;
            if (app.extractionButton.Value == 1)
                app.InputCheckBox.Enable = 0;
                app.OutputCheckBox.Enable = 0;
                for i=1:length(app.GridLayout2.Children)
                    app.GridLayout2.Children(i).ValueChangedFcn=...
                        @app.HighlightForCheckBox;
                end
            else
                app.InputCheckBox.Enable = 1;
                app.OutputCheckBox.Enable = 1;
                removeStyle(app.UITable)
                for i=1:length(app.GridLayout2.Children)
                    app.GridLayout2.Children(i).Value=0;
                    app.GridLayout2.Children(i).ValueChangedFcn=...
                        @app.HighlightForCheckBox2;
                end
            end
        end

        % Selection changed function: LayoutButtonGroup
        function LayoutButtonGroupSelectionChanged(app, event)
            selectedButton = app.LayoutButtonGroup.SelectedObject;
            if (app.CircleButton.Value == 1)
                layout(app.RawGraph.p,'circle')
            else
                layout(app.RawGraph.p,'auto')
            end
        end

        % Button pushed function: AddelementButton
        function AddelementButtonPushed(app, event)
            app.LevelsDropDown.Items(end+1)={app.NewlevelEditField.Value};
%             for i=1:
%                 app.ListBox=app.GridLayout2.Children
%             end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 989 601];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [4 10];
            app.TabGroup.Layout.Column = [1 2];

            % Create GraphTab
            app.GraphTab = uitab(app.TabGroup);
            app.GraphTab.Title = 'Graph';

            % Create GridLayout_2
            app.GridLayout_2 = uigridlayout(app.GraphTab);
            app.GridLayout_2.ColumnWidth = {'1x'};
            app.GridLayout_2.RowHeight = {'1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout_2);
            title(app.UIAxes, 'GRAPH')
            app.UIAxes.PlotBoxAspectRatio = [1.19607843137255 1 1];
            app.UIAxes.XTick = [];
            app.UIAxes.XTickLabelRotation = 0;
            app.UIAxes.YTick = [];
            app.UIAxes.YTickLabelRotation = 0;
            app.UIAxes.ZTickLabelRotation = 0;
            app.UIAxes.ClippingStyle = 'rectangle';
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create AdjacencyMatrixTab
            app.AdjacencyMatrixTab = uitab(app.TabGroup);
            app.AdjacencyMatrixTab.Title = 'Adjacency Matrix';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.AdjacencyMatrixTab);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout5.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create UITable
            app.UITable = uitable(app.GridLayout5);
            app.UITable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable.RowName = {'Row 1; Row 2; Row 3; Row 4 '};
            app.UITable.Layout.Row = [1 9];
            app.UITable.Layout.Column = [1 4];

            % Create WorkflowTab
            app.WorkflowTab = uitab(app.TabGroup);
            app.WorkflowTab.Title = 'Workflow';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.WorkflowTab);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [244 24 353 334];

            % Create Panel
            app.Panel = uipanel(app.WorkflowTab);
            app.Panel.Title = 'Panel';
            app.Panel.Position = [24 48 193 137];

            % Create AddelementButton
            app.AddelementButton = uibutton(app.Panel, 'push');
            app.AddelementButton.ButtonPushedFcn = createCallbackFcn(app, @AddelementButtonPushed, true);
            app.AddelementButton.Position = [16 46 100 23];
            app.AddelementButton.Text = 'Add element';

            % Create DeleteelementButton
            app.DeleteelementButton = uibutton(app.Panel, 'push');
            app.DeleteelementButton.Position = [16 11 100 23];
            app.DeleteelementButton.Text = 'Delete element';

            % Create ElementsDropDownLabel
            app.ElementsDropDownLabel = uilabel(app.Panel);
            app.ElementsDropDownLabel.HorizontalAlignment = 'right';
            app.ElementsDropDownLabel.Position = [17 87 55 22];
            app.ElementsDropDownLabel.Text = 'Elements';

            % Create ElementsDropDown
            app.ElementsDropDown = uidropdown(app.Panel);
            app.ElementsDropDown.Position = [87 87 100 22];

            % Create ListBoxLabel
            app.ListBoxLabel = uilabel(app.WorkflowTab);
            app.ListBoxLabel.HorizontalAlignment = 'right';
            app.ListBoxLabel.Position = [24 260 48 22];
            app.ListBoxLabel.Text = 'List Box';

            % Create ListBox
            app.ListBox = uilistbox(app.WorkflowTab);
            app.ListBox.Items = {};
            app.ListBox.Position = [87 210 100 74];
            app.ListBox.Value = {};

            % Create LevelsDropDownLabel
            app.LevelsDropDownLabel = uilabel(app.WorkflowTab);
            app.LevelsDropDownLabel.HorizontalAlignment = 'right';
            app.LevelsDropDownLabel.Position = [24 310 40 22];
            app.LevelsDropDownLabel.Text = 'Levels';

            % Create LevelsDropDown
            app.LevelsDropDown = uidropdown(app.WorkflowTab);
            app.LevelsDropDown.Items = {'Aggregate representation', 'Main representation', 'Resulting representation', 'Evaluating representation'};
            app.LevelsDropDown.Position = [88 310 101 22];
            app.LevelsDropDown.Value = 'Aggregate representation';

            % Create ElementsPanel
            app.ElementsPanel = uipanel(app.GridLayout);
            app.ElementsPanel.Title = 'Elements';
            app.ElementsPanel.Layout.Row = [1 9];
            app.ElementsPanel.Layout.Column = 3;
            app.ElementsPanel.FontWeight = 'bold';
            app.ElementsPanel.FontSize = 14;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.ElementsPanel);

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout);
            app.GridLayout10.Layout.Row = 10;
            app.GridLayout10.Layout.Column = 3;

            % Create UpdateButton
            app.UpdateButton = uibutton(app.GridLayout10, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.FontSize = 18;
            app.UpdateButton.FontWeight = 'bold';
            app.UpdateButton.Layout.Row = [1 2];
            app.UpdateButton.Layout.Column = 1;
            app.UpdateButton.Text = 'Update';

            % Create ResetButton
            app.ResetButton = uibutton(app.GridLayout10, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.IconAlignment = 'center';
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontWeight = 'bold';
            app.ResetButton.Layout.Row = [1 2];
            app.ResetButton.Layout.Column = 2;
            app.ResetButton.Text = 'Reset';

            % Create CommandpanelPanel
            app.CommandpanelPanel = uipanel(app.GridLayout);
            app.CommandpanelPanel.Title = 'Command panel';
            app.CommandpanelPanel.Layout.Row = [1 3];
            app.CommandpanelPanel.Layout.Column = [1 2];
            app.CommandpanelPanel.FontSize = 14;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.CommandpanelPanel);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x'};

            % Create LoadDataButton
            app.LoadDataButton = uibutton(app.GridLayout7, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.FontSize = 20;
            app.LoadDataButton.FontWeight = 'bold';
            app.LoadDataButton.Layout.Row = [1 2];
            app.LoadDataButton.Layout.Column = [1 2];
            app.LoadDataButton.Text = 'Load Data';

            % Create SelectoperationButtonGroup
            app.SelectoperationButtonGroup = uibuttongroup(app.GridLayout7);
            app.SelectoperationButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectoperationButtonGroupSelectionChanged, true);
            app.SelectoperationButtonGroup.Title = 'Select operation';
            app.SelectoperationButtonGroup.Layout.Row = [1 4];
            app.SelectoperationButtonGroup.Layout.Column = [3 5];
            app.SelectoperationButtonGroup.FontWeight = 'bold';
            app.SelectoperationButtonGroup.FontSize = 14;

            % Create extractionButton
            app.extractionButton = uiradiobutton(app.SelectoperationButtonGroup);
            app.extractionButton.Text = 'extraction';
            app.extractionButton.FontSize = 14;
            app.extractionButton.FontWeight = 'bold';
            app.extractionButton.Position = [19 51 89 22];
            app.extractionButton.Value = true;

            % Create connectionButton
            app.connectionButton = uiradiobutton(app.SelectoperationButtonGroup);
            app.connectionButton.Text = 'connection';
            app.connectionButton.FontSize = 14;
            app.connectionButton.FontWeight = 'bold';
            app.connectionButton.Position = [19 15 97 22];

            % Create LayoutButtonGroup
            app.LayoutButtonGroup = uibuttongroup(app.GridLayout7);
            app.LayoutButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @LayoutButtonGroupSelectionChanged, true);
            app.LayoutButtonGroup.Title = 'Layout';
            app.LayoutButtonGroup.Layout.Row = [1 4];
            app.LayoutButtonGroup.Layout.Column = [6 8];
            app.LayoutButtonGroup.FontWeight = 'bold';
            app.LayoutButtonGroup.FontSize = 14;

            % Create AutomaticButton
            app.AutomaticButton = uiradiobutton(app.LayoutButtonGroup);
            app.AutomaticButton.Text = 'Automatic';
            app.AutomaticButton.FontSize = 14;
            app.AutomaticButton.Position = [11 51 84 22];
            app.AutomaticButton.Value = true;

            % Create CircleButton
            app.CircleButton = uiradiobutton(app.LayoutButtonGroup);
            app.CircleButton.Text = 'Circle';
            app.CircleButton.FontSize = 14;
            app.CircleButton.Position = [11 15 58 22];

            % Create OutputCheckBox
            app.OutputCheckBox = uicheckbox(app.GridLayout7);
            app.OutputCheckBox.Text = 'Output';
            app.OutputCheckBox.FontSize = 14;
            app.OutputCheckBox.FontWeight = 'bold';
            app.OutputCheckBox.Layout.Row = 4;
            app.OutputCheckBox.Layout.Column = [1 2];

            % Create InputCheckBox
            app.InputCheckBox = uicheckbox(app.GridLayout7);
            app.InputCheckBox.Text = 'Input';
            app.InputCheckBox.FontSize = 14;
            app.InputCheckBox.FontWeight = 'bold';
            app.InputCheckBox.Layout.Row = 3;
            app.InputCheckBox.Layout.Column = [1 2];

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create MoveMenu
            app.MoveMenu = uimenu(app.ContextMenu);
            app.MoveMenu.Text = 'Move';
            
            % Assign app.ContextMenu
            app.UIAxes.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = UI_Graph_IJIDEM

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end