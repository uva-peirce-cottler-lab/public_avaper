// Select a directory, macro z projects and exports images, scale bars, split channels included.
//Bruce Corliss
// 11/29/2014
setBatchMode(true)

in_dir = getDirectory("Choose Source Directory ");
out_dir = in_dir + "/img/";

// Create Directory to save images
if (!File.exists(out_dir))
    File.makeDirectory(out_dir);
if (!File.exists(out_dir))
    exit("Unable to create directory");

// Loop through image in 'in_dir', process, save
list = getFileList(in_dir);

print(list[0]);

//setBatchMode(false);
for (i=0; i<list.length; i++) {
   showProgress(i+1, list.length);
   print(i);
   if (File.isDirectory(in_dir+list[i])) {
      continue;   
   }

  if (!endsWith(list[i],'ics')) { continue; }
   print("Opening: " + list[i]);
   open(in_dir+list[i]);
   master_id = getImageID();
   run("Z Project...", "projection=[Max Intensity]");

   if (nSlices > 1) {
     zproj_id = getImageID();
     selectImage(master_id);
     close();
     selectImage(zproj_id);
   }

   // Make composite
   run("Channels Tool...");
   Stack.setDisplayMode("composite");
	
   Stack.setChannel(1); run("Blue");
   Stack.setChannel(2); run("Red");
   Stack.setChannel(3); run("Green");


   Stack.setActiveChannels("111");
   run("Stack to RGB", "slices keep");
   saveAs("Tiff", out_dir + list[i] + ".tif");
   close();

   Stack.setActiveChannels("100");
   run("Stack to RGB", "slices keep");
   saveAs("Tiff", out_dir + list[i] + "_B.tif");
   close();

   Stack.setActiveChannels("010");
   run("Stack to RGB", "slices keep");
   saveAs("Tiff", out_dir + list[i] + "_R.tif");
   close();

   Stack.setActiveChannels("001");
   run("Stack to RGB", "slices keep");
   saveAs("Tiff", out_dir + list[i] + "_G.tif");
   close();
   close();
}




