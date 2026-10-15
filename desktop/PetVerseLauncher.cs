using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

internal static class PetVerseLauncher
{
    private const string AppUrl = "__PETVERSE_APP_URL__";

    [STAThread]
    private static void Main()
    {
        string[] edgePaths =
        {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
                "Microsoft", "Edge", "Application", "msedge.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86),
                "Microsoft", "Edge", "Application", "msedge.exe"),
            "msedge.exe",
        };

        foreach (string edgePath in edgePaths)
        {
            if (edgePath != "msedge.exe" && !File.Exists(edgePath))
            {
                continue;
            }

            try
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = edgePath,
                    Arguments = "--app=\"" + AppUrl + "\"",
                    UseShellExecute = true,
                });
                return;
            }
            catch (Exception)
            {
                // Try the next standard Microsoft Edge installation path.
            }
        }

        MessageBox.Show(
            "Para abrir PetVerse como una app, instalá Microsoft Edge y volvé a intentarlo.",
            "PetVerse",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information);
    }
}
