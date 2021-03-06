module TheWizardsCastle
class Castle

  attr_reader :backmap, :rooms

  def initialize
    @rooms = Array.new(8*8*8, RoomContent.to_intcode(:empty_room)) # unlike BASIC, index starts at 0

    set_in_room(1,4,1,:entrance)
    (1..7).each do |floor|
      xroom = set_in_random_room(:stairs_down,floor)
      xroom[2] = xroom[2]+1
      set_in_room(*xroom,:stairs_up)
    end

    monsters = [:kobold, :orc, :wolf, :goblin, :ogre, :troll, :bear, :minotaur, :gargoyle, :chimera, :balrog, :dragon]
    other_things = [:magic_pool, :chest, :gold, :flares, :warp, :sinkhole, :crystal_orb, :book, :vendor]
    (1..8).each do |floor|
      monsters.each {|monster| set_in_random_room(monster,floor)}
      other_things.each {|thing| 3.times { set_in_random_room(thing,floor)}}
    end

    treasures = [:ruby_red, :norn_stone, :pale_pearl, :opal_eye, :green_gem, :blue_flame, :palantir, :silmaril]
    treasures.each {|treasure| set_in_random_room(treasure)}

    # I can't believe I'm using the same empty_room hack that Stetson-BASIC is using
    # Multiple curses can be in the same room, and the runestaff/orb may also be later placed into a curse room.
    # (This is just how the old game implemented it.)
    @curse_lethargy_location      = set_in_random_room(:empty_room)
    @curse_leech_location         = set_in_random_room(:empty_room)
    @curse_forgetfulness_location = set_in_random_room(:empty_room)

    set_in_random_room(:runestaff_and_monster)
    @runestaff_monster = monsters[Random.rand(monsters.length)]

    set_in_random_room(:orb_of_zot)
  end


  def self.room_index(row,col,floor)
    # Equivalent to FND from BASIC, except -1 because @rooms is indexing from 0.
    raise "value out of range: (#{row},#{col},#{floor})" if [row,col,floor].any?{|n| n<1 || n>8}
    64*(floor-1)+8*(row-1)+col-1
  end

  def room(row,col,floor)
    RoomContent.new(@rooms[Castle.room_index(row,col,floor)])
  end

  def set_in_room(row,col,floor,symbol)
    @rooms[Castle.room_index(row,col,floor)] = RoomContent.to_intcode(symbol)
  end

  def set_in_random_room(symbol,floor=nil)
    10000.times do
      row = Random.rand(8)+1
      col = Random.rand(8)+1
      floor ||= Random.rand(8)+1
      if room(row,col,floor).symbol == :empty_room
        set_in_room(row,col,floor,symbol)
        return [row,col,floor]
      end
    end
    raise "can't find empty room"
  end

  def debug_display
    lines = []
    loc_runestaff = nil
    loc_orb_of_zot = nil

    (1..8).each do |floor|
      lines << "===LEVEL #{floor}"
      (1..8).each do |row|
        lines << " "
        (1..8).each do |col|
          rc = room(row,col,floor)
          lines.last << " "+rc.display
          loc_runestaff  = [row,col,floor] if rc.symbol==:runestaff_and_monster
          loc_orb_of_zot = [row,col,floor] if rc.symbol==:orb_of_zot
        end
      end
    end

    lines << "==="
    lines << "Curses: Lethargy=#{@curse_lethargy_location.join(',')}"
    lines.last << " Leech=#{@curse_leech_location.join(',')}"
    lines.last << " Forget=#{@curse_forgetfulness_location.join(',')}"

    lines << "Runestaff:  #{loc_runestaff.join(',')} (#{@runestaff_monster})"
    lines << "Orb of Zot: #{loc_orb_of_zot.join(',')}"

    lines
  end

end
end
