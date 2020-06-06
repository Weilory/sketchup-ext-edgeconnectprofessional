=begin
Copyright 2020, Messiz Qin
All Rights Reserved

Disclaimer
THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

License
This software is distributed under the Smustard End User License Agreement
http://www.smustard.com/eula

Information
Author - Messiz Qin
Contact - qiny@kardinia.vic.edu.au
Contact - messizqin@gmail.com
Organization - distributed on www.sketchup.com
Name - Edge Connect Professional
SU Version - 2017, 2018, 2019, 2020


Description
My purpose of this extension, is to facilitate the procedure of importing some imperfect pattens
There may be tiny edges missing, and it's extremely hard for the user to fix one by one
Professional: Pre connecting features for precious connection
Functionality:
1. Shrink selection range into a common pannel
2. Settings on Algorithm (distance, radians), Method (contineous, separate), Mode(outline, curve, cross, normal), Limit(None, set)
2. Connect selected edges | curves | connnected-edges
4. Delete crossed edges
5. Split crossed edges

Usage
select something, click on select buttom to reselect all edges in a same pannel within your selection
Set up pre-connecting features
Select parallel objects, click on one of the connecting buttoms, all edges will be connected.
For your selection, click on split buttom to split crossed edges
For your selection, click on delete buttom to delete crossed edges

History:
1.0 - 22/11/2019
Comment from the extension reviewer: We are unable to approve this extension because it defines global variables and global methods. Extensions are expected to isolate themselves in their own uniquely named root namespace (module). Have a look at our examples for reference: https://github.com/SketchUp/sketchup-ruby-api-tutorials Also, your testing instructions mentioned issues with performance and crashes. Does it actually crash, or is SU unresponsive while the extension works? We noticed that you aren't setting the second argument of model.start_operation to true - try that, it usually provide noticeable performance improvement. http://ruby.sketchup.com/Sketchup/Model.html#start_operation-instance_method It looks like the extension warns at about 150 edges - which appear to be exceptionally low. If the start_operation argument doesn't improve things i'd recommend you start a thread at the SketchUp forums and ask the community for advice.
We look forward to reviewing your next submission!

2.0 - 21/03/2020
Comment from the extension reviewer: Please use Single Root Namespace

3.0 - 24/03/2020
Approved

4.0 (PRO) - 26/03/2020

=end

require 'sketchup' unless Object.private_method_defined?(:file_loaded)
require 'extensions' unless defined?(SketchupExtension)

###
path=File.join(File.dirname(__FILE__), "edge_connect_pro", "edge_connect_main")
###
ext=SketchupExtension.new("Edge Connect Professional", path)
ext.name = "Edge Connect Professional"
ext.description = "Detailed setting on pre-connecting, one click connect all edges"
ext.version = "1.0"
ext.creator = "Messiz Qin"
ext.copyright = "2020"
Sketchup.register_extension(ext, true)
###
