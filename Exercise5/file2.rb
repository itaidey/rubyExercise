class Node

end

class NonTerminalNode < Node
  # Node[] itsNodes
  # String type (like: class, classVarDec, keyword etc..)
  def initialize (type)
    @type=type
    @itsNodes=[]
  end

  def itsNodes
    @itsNodes
  end

  def addNode(node)
    @itsNodes.push node
  end
end

class TerminalNode < Node
  def initialize (type, text)
    @type=type
    @text=text
  end

  def text
    @text
  end
  # @text
  # @type #one of: keyword, symbol, integerConstant, stringConstant, identifier
end

=begin
def writeSingleLine
  $file.syswrite('  '*(numberOfTabs) +"#{$lines[$lineNumber]}")
  return myNode + 1
end
=end

def start
  $lineNumber = 1
  myTree = NonTerminalNode.new('class')

  #writes the keyword class
  myTree.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes the class name
  myTree.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes the symbol '{'
  myTree.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #calling to classVarDec*
  while ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)] ==' static ' ||$lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]==' field ')
    myTree.addNode classVarDec
  end

  #calling to subroutineDec*
  while ($lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]==' constructor ' ||$lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]==' function '||$lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]==' method ')
    myTree.addNode subroutineDec
  end

  #writes the symbol '}'
  myTree.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myTree
end


def subroutineDec
  myNode=NonTerminalNode.new('subroutineDec')

  #writes the 'constructor'|'function'|'method'
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #write return type (can be void)
  if $keyword.include? $lines[$lineNumber]
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  else
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  end
  $lineNumber = $lineNumber+1

  #write subroutineName
  myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #write '('
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes the parameter list
  myNode.addNode parameterList

  #write ')'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes the subroutineBody
  myNode.addNode subroutineBody

  return myNode
end


def subroutineBody
  myNode = NonTerminalNode.new('subroutineBody')
  #writes '{'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #write varDec*
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] == ' var '
    #writes varDec
    myNode.addNode varDec
  end

  #write statements
  myNode.addNode statements

  #writes '}'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode
end

def statements
  myNode = NonTerminalNode.new('statements')
  temp = $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]
  while [' let ', ' if ', ' while ', ' do ', ' return '].include? temp
    temp = $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]
    if temp == ' let '
      #letStatement
      myNode.addNode letStatement
    elsif temp == ' if '
      #ifStatement
      myNode.addNode ifStatement
    elsif temp == ' while '
      #whileStatement
      myNode.addNode whileStatement
    elsif temp == ' do '
      #doStatement
      myNode.addNode doStatement
    elsif temp == ' return '
      #returnStatement
      myNode.addNode returnStatement
    end
  end
  return myNode
end

def expression
  myNode = NonTerminalNode.new('expression')

  #term
  myNode.addNode term

  #doing (op term)*
  while [' + ', ' - ', ' * ', ' / ', ' &amp; ', ' | ', ' &lt; ', ' &gt; ', ' = '].include? $lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]
    #op
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #term
    myNode.addNode term
  end

  return myNode
end

def expressionList
  myNode = NonTerminalNode.new('expressionList')

  if $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]!=' ) '

    #write expression
    myNode.addNode expression

    #doing (op term)*
    while $lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)] == ' , '

      #writes ,
      myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
      $lineNumber = $lineNumber+1

      #expression
      myNode.addNode expression

    end
  end

  return myNode
end

def letStatement
  myNode=NonTerminalNode.new('letStatement')

  #writes let
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes varName
  myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  if ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]==' [ ')

    #writes [
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes expression
    myNode.addNode expression

    #writes ]
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
  end

  #writes '='
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes expression
  myNode.addNode expression

  #writes ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode
end

def ifStatement
  myNode=NonTerminalNode.new('ifStatement')

  #writes if
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '('
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes expression
  myNode.addNode expression
  #writes ')'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '{'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes statements
  myNode.addNode statements
  #writes '}'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  if ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]==' else ')

    #writes else
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    #writes '{'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    #writes statements
    lineNumber = statements
    #writes '}'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
  end
  return myNode
end

#STOPPED HERE
#STOPPED HERE
#STOPPED HERE
#STOPPED HERE
#STOPPED HERE
def whileStatement
  myNode = NonTerminalNode.new('whileStatement')

  #writes while
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '('
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes expression
  myNode.addNode expression
  #writes ')'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '{'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes statement
  myNode.addNode statements
  #writes '}'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode

end

def doStatement

  myNode = NonTerminalNode.new('doStatement')

  #writes do
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes subroutineCall
  myNode.addNode subroutineCall myNode

  #writes ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode

end


def returnStatement

  myNode = NonTerminalNode.new('returnStatement')

  #writes return
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes expression?
  if ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]!=' ; ')
    myNode.addNode expression
  end

  #writes ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode

end


def term
  myNode = NonTerminalNode.new('term')


  #doing '(' expression ')'
  if ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]==' ( ')

    #writes '('
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #expression
    myNode.addNode expression

    #writes ')'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #doing unaryOp term
  elsif ([' ~ ', ' - '].include? $lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)])

    #writes unaryOp
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #term
    myNode.addNode term

    #doing varName '[' expression ']', there is look ahead
  elsif ($lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)]==' [ ')

    #writes varName
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes '['
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #expression
    myNode.addNode expression

    #writes ']'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #doing subroutineCall
  elsif ([' ( ', ' . '].include? $lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)])

    #subroutineCall
    myNode.addNode subroutineCall myNode

  else
    #writes integerConstant|stringConstant|keywordConstant|varName
    if $keyword.include? $lines[$lineNumber]
      myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
    elsif $lines[$lineNumber][0] == "\""
      myNode.addNode TerminalNode.new('stringConstant', $lines[$lineNumber])
    elsif $lines[$lineNumber].is_a? Numeric
      myNode.addNode TerminalNode.new('integerConstant', $lines[$lineNumber])
    else
      myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    end
    $lineNumber = $lineNumber+1
  end

  return myNode

end

def subroutineCall(myNode)
  if $lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)]==' ( '
    #writes subroutineName
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes ' ( '
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes expressionList
    lineNumber = expressionList

    #writes ')'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

  elsif $lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)] == ' . '

    #writes className|varName
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes '.'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes subroutineName
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes ' ( '
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes expressionList
    lineNumber = expressionList

    #writes ')'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
  end
end


def varDec

  myNode = NonTerminalNode.new('varDec')

  #writes var
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes type
  if $keyword.include? $lines[$lineNumber]
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  else
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  end
  $lineNumber = $lineNumber+1

  #writes varName
  myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #doing (','varName)*
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] == ' , '
    #writes ','
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes varName
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
  end

  #writing the ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode
end


def parameterList
  myNode = NonTerminalNode.new('parameterList')

  #writes until gets to ')'
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] != ' ) '
    lineNumber = writeSingleLine numberOfTabs+1, lineNumber, $lines
  end

  return myNode
end

#finished classVarDec
def classVarDec
  myNode = NonTerminalNode.new('classVarDec')

  #writing the static or field
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writing the type
  if $keyword.include? $lines[$lineNumber]
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  else
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  end

  #writing the varName
  myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #doing (','varName)*
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] == ' , '
    #writes ','
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes varName
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
  end

  #writing the ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1


  return myNode
end


#---------------Main---------------------
$keyword = %w(if class constructor function method field static var int char boolean void true false null this let do else while return)
puts 'Enter directory path: '
path = gets.strip
Dir.chdir path

files = Dir.glob '*T.xml'

if files.length == 0
  puts 'No files found'
  exit
end

def print(myTree,tabs)
  if myTree.is_a? TerminalNode
    $file.syswrite('  '*tabs+myTree.text)
  elsif myTree.is_a? NonTerminalNode
    myTree.itsNodes.each do |i|
      print i,tabs+1
    end
  end
end

for i in 0..files.length - 1 do
  $file_name=files[i][0..files[i].index('T.xml')-1]
  $file = File.new("#{$file_name}.xml", 'w')
  $lines = File.readlines("#{$file_name}T.xml")
  myTree = start
  print myTree,0
end