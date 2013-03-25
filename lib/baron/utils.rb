# Converts a number into an ordinal, 1=>1st, 2=>2nd, 3=>3rd, etc
class Fixnum
  def ordinal
    case self % 100
      when 11..13; "#{self}th"
    else
      case self % 10
        when 1; "#{self}st"
        when 2; "#{self}nd"
        when 3; "#{self}rd"
        else    "#{self}th"
      end
    end
  end
end

# Avoid a collision with ActiveSupport
class Date
  unless respond_to? :iso8601
    # Return the date as a String formatted according to ISO 8601.
    def iso8601
      ::Time.utc(year, month, day, 0, 0, 0, 0).iso8601
    end
  end
end

class String
  # Support String::bytesize in old versions of Ruby
  if RUBY_VERSION < "1.9"
    def bytesize
      size
    end
  end
  
  # Capitalize the first letter of each word in a string
  def titleize     
    self.split(/(\W)/).map(&:capitalize).join       
  end
end
