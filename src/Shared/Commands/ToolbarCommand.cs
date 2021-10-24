// Copyright (C) 2006-2008 Jim Tilander. See COPYING for and README for more details.
using EnvDTE;
using Microsoft.VisualStudio.Shell;

namespace GitExtensionsVSIX.Commands
{
    public class ToolbarCommand<TCommand> : CommandBase
        where TCommand : ItemCommandBase, new()
    {
        public ToolbarCommand(bool runForSelection = false)
        {
            RunForSelection = runForSelection;
        }

        public override void OnCommand(_DTE application, OutputWindowPane pane)
        {
            ThreadHelper.ThrowIfNotOnUIThread();

            var command = new TCommand { RunForSelection = RunForSelection };
            command.OnCommand(application, pane);
        }

        public override bool IsEnabled(_DTE application)
        {
            ThreadHelper.ThrowIfNotOnUIThread();

            return new TCommand().IsEnabled(application);
        }
    }
}
