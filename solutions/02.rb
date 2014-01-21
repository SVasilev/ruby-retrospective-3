class Criteria
  attr_accessor :assets, :not

  def initialize(assets_array, not_array)
    @assets = assets_array
    @not    = not_array
  end

  def self.status(status)
    Criteria.new([[] << status] , [])
  end

  def self.priority(priority)
    Criteria.new([[] << priority] , [])
  end

  def self.tags(tags)
    Criteria.new([] << tags, [])
  end

  def |(other)
    Criteria.new(@assets + other.assets, other.not)
  end

  def &(other)
    Criteria.new([] << @assets.flatten + other.assets.flatten, other.not)
  end

  def !
    Criteria.new([], @assets.flatten)
  end
end

class Task
  attr_accessor :text

  def initialize(line)
    @text = line
  end

  def status
    @text.split("|")[0].strip.downcase.intern
  end

  def description
    @text.split("|")[1].strip
  end

  def priority
    @text.split("|")[2].strip.downcase.intern
  end

  def tags
    return [] if @text.split("|")[3] == nil
    @text.split("|")[3].strip.split ", "
  end
end

module Comparison
  def filter(criteria)
    result_array = []
    @tasks.each { |item| result_array << match(item, criteria) }
    TodoList.new(result_array.compact)
  end

  def match(element, criteria)
    return element if criteria.assets.empty? and
           criteria.not.any? { |i| element.text.include?(convert i) == false }
    return nil if criteria.not.any? { |i| element.text.include? i.to_s }
    return element if criteria.assets.any? { |item| pass? item, element }
  end

  def pass?(array, element)
    return true if array.all? { |item| element.text.include?(convert item) }
  end

  def convert(item)
    return item if item.class == String
    return item.to_s.upcase if [:todo, :current, :done].include? item
    return item.to_s.capitalize if [:low, :normal, :high].include? item
  end
end

class TodoList
  include Enumerable
  include Comparison
  attr_accessor :tasks

  def initialize(tasks_array)
    @tasks = tasks_array
  end

  def self.parse(string)
    tasks = []
    string.split("\n").each { |item| tasks << Task.new(item) }
    TodoList.new(tasks)
  end

  def adjoin(other_list)
    result_list = @tasks + other_list.tasks
    TodoList.new(result_list)
  end

  def tasks_todo
    result = 0
    @tasks.each { |element| result += element.status.to_s.chop.count "t" }
    result
  end

  def tasks_in_progress
    result = 0
    @tasks.each { |element| result += element.status.to_s.count "c" }
    result
  end

  def tasks_completed
    result = 0
    @tasks.each { |element| result += element.status.to_s.chop.chop.count "d" }
    result
  end

  def completed?
    @tasks.all? { |element| element.status == :done }
  end

  def each(&block)
    @tasks.each &block
  end
end