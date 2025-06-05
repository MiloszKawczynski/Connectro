function addVertex(buffer, x, y, z, u, v) 
{
	vertex_position_3d(buffer, x, y, z);
	vertex_texcoord(buffer, u, v);
	vertex_color(buffer, c_white, 1);
}

function addFace(buffer, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, subimg) 
{
	addVertex(buffer, x1, y1, z1, 0.2 * subimg, 0);
	addVertex(buffer, x2, y2, z2, 0.2 * (subimg + 1), 0);
	addVertex(buffer, x3, y3, z3, 0.2 * (subimg + 1), 1);
	
	addVertex(buffer, x1, y1, z1, 0.2 * subimg, 0);
	addVertex(buffer, x3, y3, z3, 0.2 * (subimg + 1), 1);
	addVertex(buffer, x4, y4, z4, 0.2 * subimg, 1);
}

function createWall(w, h, z)
{
	vertex_format_begin();
	vertex_format_add_position_3d();
    vertex_format_add_texcoord();
	vertex_format_add_color();       
	var vformat = vertex_format_end();
	var vbuffer = vertex_create_buffer();
	
	vertex_begin(vbuffer, vformat);
	
	var size = z;
	var hsize = size / 2.0;
		
	var aspect = h / w;
		
	// Przód kostki
	addFace(vbuffer,
		-hsize, -hsize, hsize,
		hsize, -hsize, hsize,
		hsize, hsize * aspect, hsize,
		-hsize, hsize * aspect, hsize,
		4
	);
	
	// Tył kostki
	addFace(vbuffer,
		hsize, -hsize, -hsize,
		-hsize, -hsize, -hsize,
		-hsize, hsize * aspect, -hsize,
		hsize, hsize * aspect, -hsize,
		1
	);
	
	// Prawa ściana
	addFace(vbuffer,
		hsize, -hsize, hsize,
		hsize, -hsize, -hsize,
		hsize, hsize * aspect, -hsize,
		hsize, hsize * aspect, hsize,
		0
	);

	// Lewa ściana
	addFace(vbuffer,
		-hsize, -hsize, -hsize,
		-hsize, -hsize, hsize,
		-hsize, hsize * aspect, hsize,
		-hsize, hsize * aspect, -hsize,
		2
	);

	// Góra
	addFace(vbuffer,
		hsize, -hsize, hsize,
		-hsize, -hsize, hsize,
		-hsize, -hsize, -hsize,
		hsize, -hsize, -hsize,
		3
	);

	vertex_end(vbuffer);	
	
	return vbuffer;
}

function createPlane(w, h)
{
	vertex_format_begin();
	vertex_format_add_position_3d();
    vertex_format_add_texcoord();
	vertex_format_add_color();       
	var vformat = vertex_format_end();
	var vbuffer = vertex_create_buffer();
	
	vertex_begin(vbuffer, vformat);
		
    var x1 = -w/2;
    var x2 = w/2;
    
    var y1 = -h/2;
    var y2 = h/2;
    
    addVertex(vbuffer, x2, y1, 0, 1, 0);
	addVertex(vbuffer, x1, y1, 0, 0, 0);
	addVertex(vbuffer, x2, y2, 0, 1, 1);
	
    addVertex(vbuffer, x2, y2, 0, 1, 1);
	addVertex(vbuffer, x1, y1, 0, 0, 0);
	addVertex(vbuffer, x1, y2, 0, 0, 1);

	vertex_end(vbuffer);	
	
	return vbuffer;
}