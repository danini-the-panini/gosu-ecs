require_relative 'lib/gosu-ecs'

class FooWindow < Gosu::Window

  def initialize width = 800, height = 600, fullscreen = false
    super
    @engine = ECS::Engine.new

    @engine.input_system(:down, :foo_down, [:foo]) do |id, e|
      if id == Gosu::KbSpace
        puts @engine.entity_count([:position])
      end
    end

    @engine.system(:update, :foo_move, [:position, :foo]) do |dt, time, e|
      e[:position][:x] = 400+Math::cos(time)*100
      e[:position][:y] = 300+Math::sin(time)*100
      if time > 5
        puts "Time's up!"
        e[:delete] = true
      end
      e
    end

    @engine.system(:draw, :sprite_draw, [:position, :sprite]) do |e|
      x = e[:position][:x]
      y = e[:position][:y]
      img = e[:sprite][:image]
      dx = e[:sprite][:anchor][:x]*img.width
      dy = e[:sprite][:anchor][:y]*img.height
      img.draw x-dx, y-dy, 0
    end

    foo_image = Gosu::Image.from_text self, "FOO!", Gosu::default_font_name, 30
    baz_image = Gosu::Image.from_text self, "BAZ!", Gosu::default_font_name, 30

    @engine.add_entity({
      :sprite => make_sprite(foo_image),
      :position => {:x => 0, :y => 0},
      :foo => true
    })

    @engine.add_entity({
      :sprite => make_sprite(baz_image),
      :position => {:x => 100, :y => 100}
    })
  end

  def button_up id
    @engine.button_up id
  end

  def button_down id
    @engine.button_down id
  end

  def update
    @engine.update
  end

  def draw
    @engine.draw
  end

  def make_sprite image, anchor={:x => 0.5, :y => 0.5}
    {:image => image, :anchor => anchor}
  end

end

FooWindow.new.show