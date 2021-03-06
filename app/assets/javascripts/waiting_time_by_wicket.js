function WaitingTimeByWicketD3(params){
	
	if(params == null || params.data == null || 
		params.element == null || params.by == null ||
			params.kind == null){
		return null;
	};
		
	// Options defaults 
	var settings = {
			by    : params.by,
			map     : params.data,
			element : params.element,
			kind    : params.kind,
			w       : 700,
			h       : 400,
			margin  : 30
	};
	
	var init = function(){
		kindSettings();
		extract = extractors[params.by].call(this,settings.map);
		settings.map     = extract.map;
		settings.times   = extract.times;
		settings.data    = extract.data;
		settings.wickets = extract.wickets;
		settings.acount  = extract.acount;
		settings.y       = d3.scale.linear()
									.domain([0, d3.max(settings.times)])
									.range([0 + settings.margin, settings.h - settings.margin]);
		settings.x       = d3.time.scale()
									.domain([d3.min(settings.data), d3.max(settings.data)])
									.range([0 + settings.margin, settings.w - settings.margin]);

		$.extend(this,settings);
		buildGraph();
	}
	
	
	/*
		Private methods 
	*/
	
	var kindSettings = function() {
		if(settings.kind == "days"){
			settings.format = d3.time.format("%d/%m/%Y");
			settings.tick = d3.time.days;
			settings.print  = d3.time.format("%d/%m");
		}else if(settings.kind == "months"){
			settings.format = d3.time.format("%m/%Y");
			settings.tick = d3.time.months;
			settings.print  = d3.time.format("%m/%Y");
		}
	};
	
	var extractors = { 
		wicket : function(hash) {
			var times   = new Array(),
				data    = new Array(),
				wickets = new Array(),
				acount  = new Array(),
				graphs  = new Array(),
				map     = new Array(),
				colors  = d3.scale.category10();
			
			
			for (var index = hash.length - 1; index >= 0; index--){
			
				graphs.push({
					name : hash[index][0],
					id : hash[index][1][0], 
					list : hash[index][1],
					color : colors(index)
				});
			
				list = hash[index][1];
			
				map = map.concat(list);
			
				for (var x = list.length -1 ; x >= 0; x--){
					var canAdd = true, 
						date   = settings.format.parse(list[x].data);
					data.forEach(function(el) {if (settings.print(el) == settings.print(date) ) canAdd = false; })
					if( canAdd ) data.push(date);
					times.push(Math.round(list[x].time));
					acount.push(list[x].total);
				};
			};
		
			return{ times : times, 
					data : data, 
					wickets : graphs, 
					acount : acount, 
					map : map };
		},
		day : function(hash) {
			var times   = new Array(),
				data    = new Array(),
				wickets = new Array(),
				acount  = new Array(),
				graphs  = new Array(),
				map     = new Array(),
				refGraph = null,
				colors  = d3.scale.category10();


			for (var index = hash.length - 1; index >= 0; index--){
			  list = hash[index][1];
			  for (var x = list.length -1 ; x >= 0; x--){	

				graphs.forEach(function(wicket) {
					if (wicket.id == list[x].wicket_id) refGraph = wicket
				});

				if(refGraph){
				  refGraph.list.push(list[x]);
				}else {
				  graphs.push({
					name : list[x].wicket_name,
					id : list[x].wicket_id	, 
					list : [list[x]],
				    color : ""
				  });	
				}

				var canAdd = true, 
					date   = settings.format.parse(list[x].data);
				data.forEach(function(el) {if (settings.print(el) == settings.print(date) ) canAdd = false; })
				if( canAdd ) data.push(date);
				times.push(Math.round(list[x].time));
				acount.push(list[x].total);
			  };
			};

			graphs.forEach(function(w,i) {map = map.concat(w.list) ; w.color = colors(i)});			

			return{ times : times, 
					data : data, 
					wickets : graphs, 
					acount : acount, 
					map : map };
		}
	}
	
	var buildGraph = function(){
		var vis            = buildVisualization(), 
		    ruleVertical   = buildRule(vis, data, "vrule"), 
			ruleHorizontal = buildRule(vis, y.ticks(4), "hrule"),
		    lineHorizontal = buildLineHorizontal(ruleHorizontal),
			// This might look like a little confuse but if stop and think the 
			// text is alignment vertical with the horizontal lines, just like the horizontal text is with vertical lines
			textVertical   = buildTextVertical(ruleHorizontal),
			textHorizontal = buildTextHorizontal(ruleVertical);
		 	legend         = buildLegendBar(vis, wickets);
			
		for (var i = wickets.length - 1; i >= 0; i--){
				drawGraph(vis,wickets[i].list, wickets[i].color );
		};
	};
	
	var buildLegendBar = function(d3Object, elements, callback){
		
		var legendScale  =  d3.scale.linear().domain([0, elements.length]).range([0+margin, w - margin]),
		
			legend 		 =	d3Object.append("svg:g")
									.attr("class","legend");
			//Colors of Wicket correspondent to graph						
			legend.selectAll("rect")
					.data(elements)
					.enter()
					.append("svg:rect")
					.attr("width", "25")
					.attr("height","15")
					.attr("fill", function(d) {return d.color})
					.attr("x", function(d,i) { return legendScale(i); })
					.attr("y", margin);
					
            // Name of wicket to givem color
			d3Object.select("g.legend")
					.selectAll("text.legend")
					.data(elements)
					.enter()
					.append("svg:text")
					.attr("class","legend")
					.attr("x", function(d,i) { return legendScale(i); })
					.attr("y", margin)
					.attr("dx", "3em")
					.attr("dy", "1em")
					.text(function(d) {return d.name});
								  
	};

	
	var buildRule = function(d3Object, data, _class, callback){
		var objectReturn = d3Object.selectAll("g."+ _class)
								.data(data)
								.enter()
								.append("svg:g")
								.attr("class", _class);

		if(callback) callback(objectReturn);

		return objectReturn;
	};

	
	
	var drawGraph = function(d3Object, map, color, callback){
		var line		 = d3.svg.line(map)
							 .x(function(d) { return x(format.parse(d.data)); })
							 .y(function(d) { return -1 * y(d.time); }),

		   objectReturn  = d3Object.append("svg:path")
								    .style("stroke", color )
								    .attr("d", line(map));
						
		if(callback) callback(objectReturn);

		return objectReturn;
		
	};
	
	var buildVisualization = function(callback){
		
		var objectReturn=  d3.select(element)
							 .html("")
							 .append("svg:svg")
						  	 .attr("width", w + margin * 2)
							 .attr("height", h + margin * 2)
							 .append("svg:g")
							 .attr("transform", "translate("+margin+","+h+")");
				
		if(callback) callback(objectReturn);

		return objectReturn;
		
	};
	

	var buildLineVertical = function(d3Object, callback){
		var objectReturn = d3Object.append("svg:line")
								   .attr("class","x")
								   .attr("x1", x)
								   .attr("x2", x)
								   .attr("y1", 0 )
								   .attr("y2", -1 * y(d3.max(data)) )
								   .attr("text-anchor", "middle");
					
		if(callback) callback(objectReturn);

		return objectReturn;
		
	};
	
	var buildLineHorizontal = function(d3Object, callback){
		var objectReturn = d3Object.append("svg:line")
								   // .data(y.ticks(10)) 
								   .attr("class", function(d) { return d ? null : "axis"; })
								   .attr("y1",function(d) { return -1 * y(d) })
								   .attr("y2", function(d) { return -1 * y(d) })
								   .attr("x1", 0 + margin )
								   .attr("x2", x(d3.max(data)) - margin)
								   .attr("text-anchor", "middle");
					
		if(callback) callback(objectReturn);

		return objectReturn;
	};

	var buildTextVertical = function(d3Object, callback){
		var objectReturn = d3Object.append("svg:text")
								   //.data(y.ticks(4)) 
								   .attr("y", function(d) { return -1 * y(d) })
								   .attr("x", 0)
								   .attr("dx", "-2em")
								   .attr("text-anchor", "right")
								   .text(function(d) { return d + " min"});
					
		if(callback) callback(objectReturn);

		return objectReturn;
	};

	var buildTextHorizontal = function(d3Object, callback){
		var objectReturn = d3Object.append("svg:text")
								   .attr("x", x)
			       				   .attr("y", 3)
								   .attr("dy", ".1em")
								   .attr("text-anchor", "middle")
								   .text(print);
								
		if(callback) callback(objectReturn)
		
		return objectReturn;
	};
	
	init();
}

$('a.medium' ).click( function() {
	// WaitingTimeByWicketD3({element : "#center", data : json()})
	
	var form = $('form');
	var param = form.serializeArray();
	$.ajax({
		url: "/relatorios/tempo_de_espera_por_guiche",
		dataType: 'json',
		data: param,
		success: function(data){
			new WaitingTimeByWicketD3({element : "#graph", data : data});
		}
	});
});
