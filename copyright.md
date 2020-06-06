# Copyright 2020, Messiz Qin, All Rights Reserved
<br />
<h2>CITATION</h2>
<b>No other developer's code used in this project.</b><br />
<br /><br />
<hr />
<h2>DISCLAIMER</h2>
THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
<br /><br />
<hr />
<h2>LISCENSE</h2>
This software is distributed under the Smustard End User License Agreement<br />
http://www.smustard.com/eula
<br /><br />
<hr />
<h2>INFORMATION</h2>
Author - Messiz Qin<br />
Contact - messizqin@gmail.com<br />
Name - Sketchup Extension Edge Connect<br />
<a href='https://www.youtube.com/watch?v=8rAF8qulkA8'>SketchUp Extension Edge Connect Professional [YouTube]</a><br>
Connect all selected edges by one click
<br /><br />
<hr />
<h2>REQUIREMENTS</h2>
<ol>
  <li>Sketchup 2017+ installed</li>
  <li>Edge Connect Profession installed and activated</li>
</ol>
<br /><br />
<hr />
<h2>USAGE</h2>
<ol>
  <a href='https://www.youtube.com/watch?v=8rAF8qulkA8'>SketchUp Extension Edge Connect Professional [YouTube]</a><br>
  <li>reselect edges that is in the same pannel</li>
  <li>set algorithm: whether to connect from closest to furthest or connect based on bareaing magnitude</li>
  <li>set method: whenter to connect edges in a seperated manner (which means this end point is regardless of next starting point) or connect in a continuous method</li>
  <li>Set a limit or remove limit, a limit indicates the maximum length of adding edge</li>
  <li>Set mode, whether or not to add diameters to arc or connectd-edges</li>
  <li>questino mark: show information of current setting</li>
  <li>Exclamation point: execute adding edge</li>
  <li>Remove or split crossed edges</li>
</ol>
<br /><br />
<hr />
<h2>FEATURE</h2>
<ol>
  <li>Setting is memorized even if sketchup is closed</li>
  <li>Connect all edges by one click</li>
</ol>
<h2>HISTORY</h2>
1.0 - 22/11/2019
Comment from the extension reviewer: We are unable to approve this extension because it defines global variables and global methods. Extensions are expected to isolate themselves in their own uniquely named root namespace (module). Have a look at our examples for reference: https://github.com/SketchUp/sketchup-ruby-api-tutorials Also, your testing instructions mentioned issues with performance and crashes. Does it actually crash, or is SU unresponsive while the extension works? We noticed that you aren't setting the second argument of model.start_operation to true - try that, it usually provide noticeable performance improvement. http://ruby.sketchup.com/Sketchup/Model.html#start_operation-instance_method It looks like the extension warns at about 150 edges - which appear to be exceptionally low. If the start_operation argument doesn't improve things i'd recommend you start a thread at the SketchUp forums and ask the community for advice.
We look forward to reviewing your next submission!
<br /><br />
2.0 - 21/03/2020
Comment from the extension reviewer: Please use Single Root Namespace
<br /><br />
3.0 - 24/03/2020
Approved
<br /><br />
4.0 (professional version release) - 26/03/2020
