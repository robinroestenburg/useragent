require "#{File.dirname(__FILE__)}/user_agent/comparable"
require "#{File.dirname(__FILE__)}/user_agent/browsers"
require "#{File.dirname(__FILE__)}/user_agent/operating_systems"

class UserAgent
  # http://www.texsoft.it/index.php?m=sw.php.useragent
  MATCHER = %r{
    ^([^/\s]+)        # Product
    /?([^\s]*)        # Version
    (\s\(([^\)]*)\))? # Comment
  }x.freeze unless defined? MATCHER

  def self.parse(string)
    agents = []
    while m = string.match(MATCHER)
      agent = new(m[1], m[2], m[4])
      agents << agent
      string = string.sub(agent.to_s, '').strip
    end
    Browsers.extend(agents)
    agents
  end

  attr_reader :product, :version, :comment

  def initialize(product, version = nil, comment = nil)
    if product
      @product = product
    else
      raise ArgumentError, "expected a value for product"
    end

    if version && !version.empty?
      @version = version
    end

    if comment.respond_to?(:split)
      @comment = comment.split("; ")
    else
      @comment = comment
    end
  end

  include Comparable

  # Any comparsion between two user agents with different products will
  # always return false.
  def <=>(other)
    if @product == other.product
      if @version && other.version
        @version <=> other.version
      else
        0
      end
    else
      false
    end
  end

  def eql?(other)
    @product == other.product &&
      @version == other.version &&
      @comment == other.comment
  end

  def to_s
    to_str
  end

  def to_str
    if @product && @version && @comment
      "#{@product}/#{@version} (#{@comment.join("; ")})"
    elsif @product && @version
      "#{@product}/#{@version}"
    elsif @product && @comment
      "#{@product} (#{@comment.join("; ")})"
    else
      @product
    end
  end
end
