puts 'Enter directory path: '
path = gets.strip
Dir.chdir path

def analyzeLine (line)
  arr = splitBySpace (splitLine(line))
  keyword = %w(if class constructor function method field static var int char boolean void true false null this let do else while return)
  symbol = %w_| { } ( ) [ ] . , ; + - * / & < > = ~_
  arr.each do |terminal|
    if keyword.include? terminal
      $file.syswrite("<keyword> #{terminal} </keyword>\n")
    elsif symbol.include? terminal
      if terminal =='<'
        $file.syswrite("<symbol> &lt; </symbol>\n")
      elsif terminal =='>'
        $file.syswrite("<symbol> &gt; </symbol>\n")
      elsif terminal =='&'
        $file.syswrite("<symbol> &amp; </symbol>\n")
      else
        $file.syswrite("<symbol> #{terminal} </symbol>\n")
      end
    elsif terminal[0] == "\"" && terminal[terminal.length - 1] == "\""
      $file.syswrite("<stringConstant> #{terminal[1..(terminal.length - 2)]} </stringConstant>\n")
    elsif terminal.to_i.to_s == terminal
      $file.syswrite("<integerConstant> #{terminal} </integerConstant>\n")
    else
      $file.syswrite("<identifier> #{terminal} </identifier>\n")
    end
  end
end



#adds spaces between tokens
def splitLine(line)
  i = 0

  #stops =%w| $ { } ( ) [ ] ; + - * / & < > = ~ |
  stops = "|{}()[].,;+-*/&<>=~\n"

  result = ''
  while (i < line.length)
    if (stops.include?(line[i]))
      result+=' '
      result += line[i]
      i = i + 1
      result += ' '
      next
    else
      result += line[i]
      i = i + 1
    end
  end
  return result
end

def splitBySpace(line)
  inQuotes = false
  arr = []
  i = 0
  temp =''
  while (i < line.length)
    if line[i]=="\""
      temp +="\""
      inQuotes = !inQuotes
      i = i + 1
      if !inQuotes
        arr[arr.length] = temp
        temp = ''
      end
    elsif (line[i]!=' ' || inQuotes) && line[i]!="\t"
      temp += line[i]
      i = i + 1
    else
      if (temp !='' && temp!="\t" && temp!= "\n")
        arr[arr.length] = temp
        temp = ''
      end
      i = i + 1
    end
  end
  return arr
end

def removeComments (lines)
  inLongComment = false
  arr = []
  i = 0
  j = 0
  while i < lines.length
    line = lines[i]
    arr[j] = ''


    #if you need to move '//' comment
    if ((line.include?('//') && !line.include?('/*')) || (line.include?('//') && line.include?('/*') && line.index('//') < line.index('/*'))) && !inLongComment
      if (line.index('//') != 0)
        arr[j] += line[0..line.index('//')-1]
        j = j + 1
      end
      i = i + 1;

      # if there is '/*' comment
    elsif line.include?('/*') && !inLongComment
      #if there isn't  '*/' in the same line
      if (!line.include?('*/'))
        inLongComment = !inLongComment
        if (line.index('/*') != 0)
          arr[j] += line[0..line.index('/*') - 1]
        end
        i = i + 1

        #if there is '*/' in the same line
      else
        if line.index('/*') != 0
          temp = line[0..line.index('/*')- 1]
          temp += line[line.index('*/')+2 .. line.length]
          lines[i] = temp
        else
          lines[i] = line[line.index('*/')+2 .. line.length]
        end
      end
      #if we are in the end of '*/'
    elsif inLongComment && line.include?('*/')
      lines[i] = line[line.index('*/') + 2 ..line.length]
      inLongComment = !inLongComment
      #if the line isn't a comment
    elsif !inLongComment
      arr[j] += line
      i = i + 1
      j = j + 1
      #if we are in a long comment and the line needs the be removed
    elsif inLongComment
      i = i + 1
    end
  end
  return arr
end


files = Dir.glob '*.jack'
for i in 0..files.length - 1 do
  $file_name=files[i]
  $file = File.new("#{$file_name.split('.')[0]}T1.xml", 'w')
  $file.syswrite "<tokens>\n"
  lines = File.readlines($file_name)
  lines = removeComments lines
  lines.each do |line|
    analyzeLine(line)
  end

  $file.syswrite "</tokens>\n"
end

if files.length == 0
  puts 'No files found'
end