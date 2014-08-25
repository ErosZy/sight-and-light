package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[SWF(width="640",height="360",frameRate="60")]
	public class signAndLight extends Sprite
	{
		private var polygons:Array = [
			// Border
			[{x:0,y:0},{x:640,y:0},
			{x:640,y:360},{x:0,y:360},
			{x:0,y:0}],
			
			// Polygon #1
			[{x:100,y:150}, {x:120,y:50},
			{x:200,y:80},{x:140,y:210},
			{x:100,y:150}],
			
			// Polygon #2
			[{x:100,y:200}, {x:120,y:250},
			{x:60,y:300},{x:100,y:200}],
			
			// Polygon #3
			[{x:200,y:260}, {x:220,y:150},
			{x:300,y:200},{x:350,y:320},
			{x:200,y:260}],
			
			// Polygon #4
			[{x:340,y:60}, {x:360,y:40},
			{x:370,y:70},{x:340,y:60}],
			
			// Polygon #5
			[{x:450,y:190}, {x:560,y:170},
			{x:540,y:270}, {x:430,y:290},
			{x:450,y:190}],
			
			// Polygon #6
			[{x:400,y:95}, {x:580,y:50},
			{x:480,y:150},{x:400,y:95}]
			
		];
		
		private var angles:Array = new Array();
		
		public function signAndLight()
		{
			
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onEneterFrame);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		protected function onEneterFrame(event:MouseEvent):void
		{
			clearStage();
			drawSquare();
			drawMouseCircle();
		}
		
		private function clearStage():void
		{
			graphics.clear();
		}
		
		private function drawSquare():void
		{
			for(var i:int = 1; i < polygons.length; i++)
			{
				graphics.lineStyle(1);
				for(var j:int = 0; j < polygons[i].length; j++)
				{
					if(!j)
					{
						graphics.moveTo(polygons[i][j].x,polygons[i][j].y);		
					}else{
						graphics.lineTo(polygons[i][j].x,polygons[i][j].y);
					}
				}
			}
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			drawMouseCircle();
			drawLines();
			event.updateAfterEvent();
		}
		
		private function drawMouseCircle():void
		{
			graphics.beginFill(0xff0000);
			graphics.drawCircle(mouseX,mouseY,5);
			graphics.endFill();
		}
		
		private function drawLines():void
		{
			var cPolygons:Array = filterPolygons();
			var dx:Number = 0,dy:Number = 0,angle:Number = 0;
			var ray:Object = {}, segment:Object = {},intersect:Object={},intersects:Array=[];
			var i:int,j:int,k:int;
			
			angles = [];
			for(i = 0; i < cPolygons.length; i++)
			{
				for(j = 0; j < cPolygons[i].length; j++)
				{
					dy = cPolygons[i][j].y - mouseY;
					dx = cPolygons[i][j].x - mouseX;
					angle = Math.atan2(dy,dx);
					angles.push(angle-0.0001,angle,angle+0.0001);
				}
			}
			
			var bestIntersection:Object = null;
			for(k = 0; k < angles.length; k++){
				angle = angles[k];
				dx = Math.cos(angle);
				dy = Math.sin(angle);
				ray = {
					a:{x:mouseX,y:mouseY},
					b:{x:mouseX+dx,y:mouseY+dy}
				};
				
				
				bestIntersection = null;
				for(i = 0; i < polygons.length; i++)
				{
					for(j = 0; j < polygons[i].length - 1; j++)
					{
						segment = {
							a:{x:polygons[i][j].x,y:polygons[i][j].y},
							b:{x:polygons[i][j+1].x,y:polygons[i][j+1].y}
						};
						
						intersect = getIntersection(ray,segment);
						if(!intersect) continue;
						if(!bestIntersection || bestIntersection.param > intersect.param)
						{
							bestIntersection = intersect;
						}
					}
				}
				
				intersects.push(bestIntersection);
			}
			drawPolygons(intersects);
		}
		
		private function drawPolygons(p:Array):void
		{
			graphics.lineStyle(2,0xff0000);
			
			for(var i:int = 0 ; i < p.length; i++)
			{
				graphics.moveTo(mouseX,mouseY);
				graphics.lineTo(p[i].x,p[i].y);
			}
		}
		
		private function filterPolygons():Array
		{
			var obj:Object = {};
			var tmp:Array = [];
			
			for(var i:int = 0; i < polygons.length; i++)
			{
				tmp[i] = [];
				for(var j:int = 0; j < polygons[i].length; j++)
				{
					var key:String = "x:"+polygons[i][j].x+"---"+"y:"+polygons[i][j].y;
					if(key in obj)
					{
						continue;
					}else{
						obj[key] = 1;
						tmp[i].push(polygons[i][j]);
					}
				}
			}
			
			return tmp;
		}
		
		private function getIntersection(ray,segment):*
		{
			var r_px:Number = ray.a.x;
			var r_py:Number = ray.a.y;
			var r_dx:Number = ray.b.x-ray.a.x;
			var r_dy:Number = ray.b.y-ray.a.y;
			
			var s_px:Number = segment.a.x;
			var s_py:Number = segment.a.y;
			var s_dx:Number = segment.b.x-segment.a.x;
			var s_dy:Number = segment.b.y-segment.a.y;
			
			var r_mag:Number = Math.sqrt(r_dx*r_dx+r_dy*r_dy);
			var s_mag:Number = Math.sqrt(s_dx*s_dx+s_dy*s_dy);
			if(r_dx/r_mag==s_dx/s_mag && r_dy/r_mag==s_dy/s_mag){
				return null;
			}
			
			var T2:Number = (r_dx*(s_py-r_py) + r_dy*(r_px-s_px))/(s_dx*r_dy - s_dy*r_dx);
			var T1:Number = (s_px+s_dx*T2-r_px)/r_dx;
			
			if(T1<0) return null;
			if(T2<0 || T2>1) return null;
			
			return {
				x: r_px+r_dx*T1,
				y: r_py+r_dy*T1,
				param: T1
			};
			
		}
	}
}