delegate BrwRowCondition(val as int) as logic

class Test
	public method AddColorCondition(uCondition as BrwRowCondition) as logic
		var x := uCondition(1)
		return x
end class



function Start() as void strict
	local test := Test{} as object

	test:AddColorCondition({val => val > 0})

	return
