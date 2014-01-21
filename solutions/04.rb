module BasicMethods
  def mov(destination_register, source)
    @lines[@lines_counter] = [:mov_instruction, destination_register, source]
    @lines_counter += 1
  end

  def inc(destination_register, source = 1)
    @lines[@lines_counter] = [:inc_instruction, destination_register, source]
    @lines_counter += 1
  end

  def dec(destination_register, source = 1)
    @lines[@lines_counter] = [:dec_instruction, destination_register, source]
    @lines_counter += 1
  end

  def cmp(register, value)
    @lines[@lines_counter] = [:cmp_instruction, register, value]
    @lines_counter += 1
  end

  def label(label_name)
    @lines[label_name] = @lines_counter
  end
end

module JumpMethods
  def jmp(where)
    @lines[@lines_counter] = [:jmp_instruction, where]
    @lines_counter += 1
  end

  def je(where)
    @lines[@lines_counter] = [:je_instruction, where]
    @lines_counter += 1
  end

  def jne(where)
    @lines[@lines_counter] = [:jne_instruction, where]
    @lines_counter += 1
  end

  def jl(where)
    @lines[@lines_counter] = [:jl_instruction, where]
    @lines_counter += 1
  end

  def jle(where)
    @lines[@lines_counter] = [:jle_instruction, where]
    @lines_counter += 1
  end

  def jg(where)
    @lines[@lines_counter] = [:jg_instruction, where]
    @lines_counter += 1
  end

  def jge(where)
    @lines[@lines_counter] = [:jge_instruction, where]
    @lines_counter += 1
  end
end


module BasicInstructions
  def mov_instruction(destination_register, source)
    @registers[:ex] = source.class == Fixnum ? source : @registers[source]
    @registers[destination_register] = @registers[:ex]
  end

  def inc_instruction(destination_register, source = 1)
    @registers[:ex] = source.class == Fixnum ? source : @registers[source]
    @registers[destination_register] += @registers[:ex]
  end

  def dec_instruction(destination_register, source = 1)
    @registers[:ex] = source.class == Fixnum ? source : @registers[source]
    @registers[destination_register] -= @registers[:ex]
  end

  def cmp_instruction(register, value)
    @registers[:ex] = value.class == Fixnum ? value : @registers[value]
    @last_compare_value = @registers[register] <=> @registers[:ex]
  end
end

module JumpInstructions
  def jmp_instruction(where)
    where = where.class != Fixnum ? @lines[where] : where
  end

  def je_instruction(where)
    @last_compare_value == 0 ? jmp_instruction(where) : 0
  end

  def jne_instruction(where)
    @last_compare_value != 0 ? jmp_instruction(where) : 0
  end

  def jl_instruction(where)
    @last_compare_value == -1 ? jmp_instruction(where) : 0
  end

  def jle_instruction(where)
    @last_compare_value < 1 ? jmp_instruction(where) : 0
  end

  def jg_instruction(where)
    @last_compare_value == 1 ? jmp_instruction(where) : 0
  end

  def jge_instruction(where)
    @last_compare_value > -1 ? jmp_instruction(where) : 0
  end
end

module Asm
  include BasicMethods
  include JumpMethods
  include BasicInstructions
  include JumpInstructions
  extend self
  def asm(&block)
    @registers = { :ax => 0, :bx => 0, :cx => 0, :dx => 0, :ex => 0 }
    @lines, @lines_counter, @last_compare_value = {},  0, -2
    instance_eval &block
    compile
    @registers.values.take 4
  end

  def compile
    @lines.each_value do |value|
      if value[0].to_s[0] == "j" and value[1].class != Fixnum
        value[1] = @lines[value[1]]
      end
    end
    @lines.each_key { |key| @lines.delete key if key.class != Fixnum }
    main_loop
  end

  def execute_jump_instruction(i)
    if send(@lines[i][0], @lines[i][1]) != 0
      i = send @lines[i][0], @lines[i][1] - 1
    end
    i
  end

  def execute_normal_instruction(i)
    send @lines[i][0], @lines[i][1], @lines[i][2] if @lines[i].class == Array
    i
  end

  def execute_instruction(i)
    if @lines[i][0].to_s[0] == "j"
      execute_jump_instruction(i)
    else
      execute_normal_instruction(i)
    end
  end

  def main_loop
    iteration = 0
    while(iteration < @lines.length)
      iteration = execute_instruction(iteration)
      iteration += 1
    end
  end

  def method_missing(method)
    method
  end
end