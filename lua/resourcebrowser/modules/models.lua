local MODULE = {}
MODULE.name			= "Model Viewer"
MODULE.author		= "Th13teen"
MODULE.fileTypes = { "mdl" }

function MODULE:SpawnUI( fileName, filePath )

	local Size = math.Clamp( ( ScrH() * 0.75 ), 700, math.huge )

	self.frame = vgui.Create( "DFrame" )
	self.frame:SetSize( Size * 0.8, Size )
	self.frame:SetTitle( "Model Viewer - " .. fileName )

	--I'm creating it this way because it gives us more access
	local mdl = ents.CreateClientProp( fileName )
	mdl:SetNoDraw( true )

	--Widget
	local widget = ents.CreateClientProp( "models/maxofs2d/cube_tool.mdl" )
	widget:SetNoDraw( true )

	local model = vgui.Create( "DPanel", self.frame )
	local tools = vgui.Create( "DPanel", self.frame )
	local div = vgui.Create( "DVerticalDivider", self.frame )
	div:SetTop( model )
	div:SetBottom( tools )
	div:Dock( FILL )
	div:SetTopHeight( ( self.frame:GetTall() / 3 ) * 2 )
	model:Dock( TOP )
	tools:Dock( BOTTOM )

	model.Paint = function ( pnl )

		local x, y = pnl:LocalToScreen( 0, 0 )
		local w, h = pnl:GetSize()

		derma.SkinHook( "Paint", "Panel", pnl, w, h )

		local Ang = Angle( 0, RealTime() * 40, 0 )
		local Pos = Ang:Forward() * -128

		cam.Start3D( Pos, Ang, LocalPlayer():GetFOV(), x, y, w, h, 1, 4096 )

			cam.IgnoreZ( false )
			render.SuppressEngineLighting( true )

			--Drawing Starts
			mdl:SetNoDraw( false )
			mdl:DrawModel()
			mdl:SetNoDraw( true )
			--Drawing Ends

			render.SuppressEngineLighting( false )

		cam.End3D()

		cam.Start3D( ( Ang:Forward() * -64 ), Ang, 40, x, y, h/6, h/6, 32, 128 )

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

	self.frame.OnClose = function( pnl )
		mdl:Remove()
		widget:Remove()
	end

	self.frame:Center()
	self.frame:MakePopup()

	return true

end

resourceBrowser.registerModule( MODULE )