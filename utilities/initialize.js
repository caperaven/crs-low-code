/* eslint-disable no-undef */

// Import Deno's file system module
const createFolders = async (rootPath) => {
  try {
    // Define the .lowcode folder and its subfolders
    const lowcodeFolder = `${rootPath}/.lowcode`;
    const subfolders = ["models", "templates"];

    // Create the .lowcode folder if it doesn't exist
    await Deno.mkdir(lowcodeFolder, { recursive: true });
    console.log(`Created folder: ${lowcodeFolder}`);

    // Create each subfolder inside .lowcode
    for (const folder of subfolders) {
      const subfolderPath = `${lowcodeFolder}/${folder}`;
      await Deno.mkdir(subfolderPath, { recursive: true });
      console.log(`Created subfolder: ${subfolderPath}`);
    }
  } catch (error) {
    console.error("Error creating folders:", error.message);
  }
};

// Get the root folder path from the command-line arguments
if (import.meta.main) {
  const args = typeof Deno !== "undefined" ? Deno.args : process.argv.slice(2);
  const rootPath = args.length === 1 ? args[0] : (typeof Deno !== "undefined" ? Deno.cwd() : process.cwd()); // Use current folder if no parameter is provided
  if (args.length > 1) {
    console.error("Usage: deno run --allow-write initialize.js [<root-folder-path>]");
    if (typeof Deno !== "undefined") {
      Deno.exit(1);
    } else {
      process.exit(1);
    }
  }

  await createFolders(rootPath);
}