# <a href='https://ruby.sketchup.com/Sketchup/Model.html'>@ SketchUp Ruby API</a>
<h2>Structure</h2>
<u>required format: </u>major folder named <b><u>`EdgeConnect4.0`</b></u> <u>(extname + version)</u>, two parts with same name goes into the folder, one is a rb file <b>`edge_connect_pro.rb`</b>, another is a folder <b>`edge_connect_pro`</b>. 
<br /><br />
<b>`edge_connect_pro.rb`</b>: 
<ol><li>require sketchup and extensions module if they haven't been loaded</li>
<li>register extension with information of its path('edge_connect_main'), name (don't use abbreviation here), description, version, creator</li></ol>
<br />
inside `edge_connect_pro` subfolder, 
<br />
<ol>
	<li><h3>`edge_connect_main.rb`</h3>
		<p>This connect all stuff together. Specificly, it loads sketchup module if it haven't been loaded, then it manages all files in the directory and link each png image to its function</p>
	</li>
	<li><h3>`mq_edge_connect_module.rb`</h3>
		<p>This is the main code. <b>No global variable allowed</b>, since all code is put into a unique module with your name. <b>don't use `exit` `quit` command, it bascially kills the ruby interpreter</b></p>
	</li>
	<li><h3>`mq_cache.txt`</h3>
		<p>store settings</p>
	</li>
	<li><h3>`edge_connect_images`</h3>
		<p>contains png square images</p>
	</li>
</ol>
<br /><br />
<hr />
<h2>Algorithm</h2>
<ol><b>Cartesian to radians:</b>
	<li>distance = (x * x + y * y) ** 0.5</li>
	<li>radians = Math.atan(y / x.to_f)</li>
</ol>
<br />
<ol><b>Cartesian to phi:</b><br />
	<u>phi is a measure of radians that start from positive y axis and move anticlockwisely all the way back to positive y axis</u>
	<li>distance = (x * x + y * y) ** 0.5</li>
	<li>radians = Math.atan(y / x.to_f)</li>
	<li>
		if (x > 0 && y > 0) || (x > 0 && y < 0) # quadrant 1 and 4<br />
          &nbsp;&nbsp;phi = Math::PI / 2.0 - radians<br />
        else # quadrant 2 and 3<br />
          &nbsp;&nbsp;phi = 3 * Math::PI / 2.0 - radians<br />
        end
    </li>
</ol>