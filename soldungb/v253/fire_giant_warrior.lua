-- Example disabling spawn based on spawngroupid
function prepare_spawn(e)
	-- This guy wanders into Nagafen's room
	if e.self:GetSp2() == 4553 then
		return -1;
	end

	return 0;
end
