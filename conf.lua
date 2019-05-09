function love.conf(t)
    t.version = "11.1"
    t.modules.window = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.data = true
    t.modules.timer = true
    t.modules.event = true
    t.modules.math = true
    t.modules.physics = false
    t.modules.video = false
    t.modules.graphics = true
    t.modules.image = true
    t.modules.font = false
    t.modules.audio = true
    t.modules.sound = true
    t.modules.keyboard = false
    t.modules.mouse = true
    t.modules.touch = true
    t.modules.joystick = false
    t.accelerometerjoystick = false
end