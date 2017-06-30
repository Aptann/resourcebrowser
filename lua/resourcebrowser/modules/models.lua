local MODULE = {}
MODULE.name			= "Model Viewer"
MODULE.author		= "Th13teen"
MODULE.fileTypes = { "mdl" }

function MODULE:SpawnUI( fileName, filePath )

	self.frame = vgui.Create( "DFrame" )
	self.frame:SetSize( ScrW() * 0.8, ScrH() * 0.8 )
	self.frame:SetTitle( "Model Viewer - " .. fileName )

	local sky = Material( "models/wireframe" )

	--I'm creating it this way because it gives us more access
	util.PrecacheModel( filePath )
	local mdl = ClientsideModel( filePath, RENDERGROUP_BOTH )
	mdl:SetNoDraw( true )

	--Widget
	util.PrecacheModel( "models/maxofs2d/cube_tool.mdl" )
	local widget = ents.CreateClientProp( "models/maxofs2d/cube_tool.mdl" )
	widget:SetNoDraw( true )

	local model = vgui.Create( "DPanel", self.frame )
	-- local tools = vgui.Create( "DPanel", self.frame )
	-- local div = vgui.Create( "DHorizontalDivider", self.frame )
	-- div:SetLeft( model )
	-- div:SetRight( tools )
	-- div:Dock( FILL )
	-- div:SetLeftWidth( ( self.frame:GetWide() / 4 ) * 3 )
	model:Dock( FILL )
	model.pos = mdl:GetPos() + mdl:OBBCenter()
	model.ang = Vector( -1, 0, 0 ):Angle()
	model.moving = false
	model.binds = {}
	model.binds.forward = _G[ "KEY_"..string.upper( input.LookupBinding( "+forward" ) ) ]
	model.binds.left = _G[ "KEY_"..string.upper( input.LookupBinding( "+moveleft" ) ) ]
	model.binds.right = _G[ "KEY_"..string.upper( input.LookupBinding( "+moveright" ) ) ]
	model.binds.back = _G[ "KEY_"..string.upper( input.LookupBinding( "+back" ) ) ]
	-- tools:Dock( RIGHT )
	-- local options = vgui.Create( "DProperties", tools )
	-- options:Dock( FILL )

	-- local wireframe = options:CreateRow( "Model Viewer Options", "Wireframe" )
	-- wireframe:Setup( "boolean" )
	-- wireframe:SetValue( false )
	-- local cam_loc = options:CreateRow( "Model Viewer Options", "Camera Location" )
	-- cam_loc:Setup( "vector" )
	-- cam_loc:SetValue( model.pos )
	-- local cam_ang = options:CreateRow( "Model Viewer Options", "Camera Angle" )
	-- cam_ang:Setup( "angle" )
	-- cam_ang:SetValue( model.ang )
	-- local ground = options:CreateRow( "Model Viewer Options", "Ground Enable" )
	-- ground:Setup( "angle" )
	-- ground:SetValue( true )
	-- local ground_size = options:CreateRow( "Model Viewer Options", "Ground Scale" )
	-- ground_size:Setup( "integer" )
	-- ground_size:SetValue( 256 )
	-- local ground_base = options:CreateRow( "Model Viewer Options", "Set ground at base" )
	-- ground_base:Setup( "boolean" )
	-- ground_base:SetValue( false )

	model.Paint = function ( pnl )

		local x, y = pnl:LocalToScreen( 0, 0 )
		local w, h = pnl:GetSize()

		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( 0, 0, w, h )

		--Updating movement
		if ( pnl.moving ) then

			--Rotation
			local centx, centy = x+(w/2), y+(h/2)
			local cx, cy = input.GetCursorPos()
			pnl.ang = pnl.ang + Angle( (cy-centy)*0.25, -(cx-centx)*0.25, 0 )
			input.SetCursorPos( x+(w/2), y+(h/2) )

			--Position
			local f = input.IsKeyDown( pnl.binds.forward ) or input.IsKeyDown( KEY_UP )
			local l = input.IsKeyDown( pnl.binds.left ) or input.IsKeyDown( KEY_LEFT )
			local r = input.IsKeyDown( pnl.binds.right ) or input.IsKeyDown( KEY_RIGHT )
			local b = input.IsKeyDown( pnl.binds.back ) or input.IsKeyDown( KEY_DOWN )
			if ( f ) then pnl.pos = pnl.pos + ( pnl.ang:Forward() * 270 * FrameTime() ) end
			if ( l ) then pnl.pos = pnl.pos + ( -pnl.ang:Right() * 270 * FrameTime() ) end
			if ( r ) then pnl.pos = pnl.pos + ( pnl.ang:Right() * 270 * FrameTime() ) end
			if ( b ) then pnl.pos = pnl.pos + ( -pnl.ang:Forward() * 270 * FrameTime() ) end
		end
		--End

		local pos = pnl.pos
		local ang = pnl.ang

		cam.Start3D( pos, ang, LocalPlayer():GetFOV(), x, y, w, h, 1, 4096 )

			cam.IgnoreZ( false )
			render.SuppressEngineLighting( true )

			render.SetMaterial( sky )
			render.DrawQuadEasy( Vector( 0, 0, 0 ), Vector( 0, 0, 1 ), 256, 256, Color( 255, 255, 255, 255 ), 0 )

			--Drawing Starts
			mdl:SetNoDraw( false )
			mdl:DrawModel()
			mdl:SetNoDraw( true )
			--Drawing Ends

			render.SuppressEngineLighting( false )

		cam.End3D()

		cam.Start3D( ( ang:Forward() * -128 ), ang, 15, x, y, h/6, h/6, 64, 256 )

			cam.IgnoreZ( false )
			render.SuppressEngineLighting( true )

			--Drawing Starts
			widget:SetNoDraw( false )
			widget:DrawModel()
			widget:SetNoDraw( true )
			--Drawing Ends

			render.SuppressEngineLighting( false )

		cam.End3D()

	end
	
	model.OnMousePressed = function( pnl, code )
		local x, y = pnl:LocalToScreen( 0, 0 )
		local w, h = pnl:GetSize()
		if ( code == 107 ) then
			RememberCursorPosition()
			pnl:SetCursor( "blank" )
			input.SetCursorPos( x+(w/2), y+(h/2) )
			model.moving = true
		elseif ( code == 108 ) then
			--Right Click
		end
	end

	model.OnMouseReleased = function( pnl, code )
		if ( code == 107 ) then
			RestoreCursorPosition()
			pnl:SetCursor( "arrow" )
			model.moving = false
		elseif ( code == 108 ) then
			--Right Click
		end
	end

	self.frame.OnClose = function( pnl )
		mdl:Remove()
		widget:Remove()
	end

	self.frame:Center()
	self.frame:MakePopup()

	return true

end

resourceBrowser.registerModule( MODULE )