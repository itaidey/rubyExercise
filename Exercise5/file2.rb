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

  def type
    @type
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


class MySymbol

  def initialize (name, type, kind, number)
    # Instance variables
    @name = name
    @type = type
    @kind = kind
    @number = number
  end

  def getName
    @name
  end

  def getType
    @type
  end

  def getKind
    @kind
  end

  def getNumber
    @number
  end

  def myPrint
    puts @name +' : ' +@type +' : ' + @kind +' : ' + @number.to_s+';'
  end

end

class SymbolTable

  def initialize
    @symbols = Array.new
  end

  def clear
    @symbols.clear
  end

  def addSymbol(name, type, kind)
    @symbols.push(MySymbol.new(name, type, kind, maxKind(kind) + 1))
  end

  def getKindByName name
    for i in 0..(@symbols.length) -1
      if @symbols[i].getName == name
        return @symbols[i].getKind
      end
    end
    return nil
  end

  def getNumberByName name
    for i in 0..(@symbols.length) -1
      if @symbols[i].getName == name
        return @symbols[i].getNumber
      end
    end
    return -1
  end

  def getNumOfFields
    num = 0
    for i in 0..(@symbols.length) -1
      if @symbols[i].getKind =='field'
        num = num + 1
      end
    end
    return num
  end

  def getSymbolNum
    return @symbols.length
  end

  def maxKind(kind)
    num = -1
    if @symbols == nil
      return -1
    end

    for i in 0.. (@symbols.length) -1
      if @symbols[i].getKind == kind && @symbols[i].getNumber >= num
        num = @symbols[i].getNumber
      end
    end
    return num
  end

  def myPrint
    if @symbols == nil
      puts 'empty'
      puts
      return
    end
    for i in 0.. (@symbols.length) -1
      @symbols[i].myPrint
    end
    puts
  end
  def getTypeByName name
    for i in 0..(@symbols.length) -1
      if @symbols[i].getName == name
        return @symbols[i].getType
      end
    end
    return nil
  end
end

def getVmKindBySymbolKind kind
  if kind =='var'
    return 'local'
  elsif kind =='argument'
    return 'argument'
  elsif kind =='static'
    return 'static'
  elsif kind == 'field'
    return 'this'
  end
end
=begin
def writeSingleLine
  $file.syswrite('  '*(numberOfTabs) +"#{$lines[$lineNumber]}")
  return myNode + 1
end
=end

def extract
  return $lines[$lineNumber][($lines[$lineNumber].index('>')+2)..($lines[$lineNumber].index(' </')-1)]
end

def start
  $lineNumber = 1
  myTree = NonTerminalNode.new('class')

  #writes the keyword class
  myTree.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes the class name
  if $file_name != extract
    abort 'ERROR - file name does not match class name'
  end
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
  myNode = NonTerminalNode.new('subroutineDec')


  #initializing the methodSymbolTable
  $methodScopeSymbolTable.clear
  $localVariablesNum = 0
  #writes the 'constructor'|'function'|'method'
  if extract == 'method'
    $methodScopeSymbolTable.addSymbol 'this', $file_name, 'argument'
  end
  subroutineKind = extract
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #write return type (can be void)
  if $keyword.include? extract
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  else
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  end
  $lineNumber = $lineNumber+1

  #write subroutineName
  subroutineName = extract
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
  myNode.addNode subroutineBody subroutineKind, subroutineName

  puts '$methodScopeSymbolTable before delete:'
  $methodScopeSymbolTable.myPrint

  return myNode
end


def subroutineBody subroutineKind, subroutineName
  myNode = NonTerminalNode.new('subroutineBody')
  #writes '{'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1


  #write varDec*
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] == ' var '
    #writes varDec
    myNode.addNode varDec
  end
  $vmFile.syswrite "function #{$file_name}.#{subroutineName} #{$localVariablesNum}\n"
  if subroutineKind == 'method'
    $vmFile.syswrite "push argument 0\npop pointer 0\n"
  elsif subroutineKind == 'constructor'
    $vmFile.syswrite "push constant #{$classScopeSymbolTable.getNumOfFields}\n"
    $vmFile.syswrite "call Memory.alloc 1\n"
    $vmFile.syswrite "pop pointer 0\n"
  end

  #write statements
  myNode.addNode statements subroutineKind

  #writes '}'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode
end

def statements subroutineKind
  myNode = NonTerminalNode.new('statements')
  temp = $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]
  while [' let ', ' if ', ' while ', ' do ', ' return '].include? temp
    temp = $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]
    if temp == ' let '
      #letStatement
      myNode.addNode letStatement
    elsif temp == ' if '
      #ifStatement
      myNode.addNode ifStatement subroutineKind
    elsif temp == ' while '
      #whileStatement
      myNode.addNode whileStatement subroutineKind
    elsif temp == ' do '
      #doStatement
      myNode.addNode doStatement
    elsif temp == ' return '
      #returnStatement
      myNode.addNode returnStatement subroutineKind
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
    op = extract


    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #term
    myNode.addNode term
    if op == '+'
      $vmFile.syswrite "add\n"
    elsif op == '-'
      $vmFile.syswrite "sub\n"
    elsif op == '/'
      $vmFile.syswrite "call Math.divide 2\n"
    elsif op == '&lt;'
      $vmFile.syswrite "lt\n"
    elsif op =='&gt;'
      $vmFile.syswrite "gt\n"
    elsif op =='&amp;'
      $vmFile.syswrite "and\n"
    elsif op =='='
      $vmFile.syswrite "eq\n"
    elsif op =='|'
      $vmFile.syswrite "or\n"
    elsif op =='*'
      $vmFile.syswrite "call Math.multiply 2\n"
    end
  end
  return myNode
end

def expressionList
  myNode = NonTerminalNode.new('expressionList')

  $argNumber = 0
  if $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1]!=' ) '

    $argNumber += 1;
    #write expression
    myNode.addNode expression

    #doing (, expression)*
    while $lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)] == ' , '

      #writes ,
      myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
      $lineNumber = $lineNumber+1

      $argNumber += 1;
      #expression
      myNode.addNode expression

    end
  end

  return myNode
end

def letStatement
  myNode=NonTerminalNode.new('letStatement')
  arrayFlag =false
  #writes let
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes varName
  name = extract
  myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  if ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]==' [ ')
    arrayFlag = !arrayFlag
    #writes [
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes expression
    myNode.addNode expression

    #writes ]
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    if ($methodScopeSymbolTable.getNumberByName name) != -1
      $vmFile.syswrite "push #{getVmKindBySymbolKind ($methodScopeSymbolTable.getKindByName name)} #{$methodScopeSymbolTable.getNumberByName name}\n"
    else
      $vmFile.syswrite "push #{getVmKindBySymbolKind ($classScopeSymbolTable.getKindByName name)} #{$classScopeSymbolTable.getNumberByName name}\n"
    end
    $vmFile.syswrite"add\n"
  end

  #writes '='
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes expression
  myNode.addNode expression

  if !arrayFlag
    if ($methodScopeSymbolTable.getNumberByName name) != -1
      $vmFile.syswrite "pop #{getVmKindBySymbolKind ($methodScopeSymbolTable.getKindByName name)} #{$methodScopeSymbolTable.getNumberByName name}\n"
    else
      $vmFile.syswrite "pop #{getVmKindBySymbolKind ($classScopeSymbolTable.getKindByName name)} #{$classScopeSymbolTable.getNumberByName name}\n"
    end
  else
    $vmFile.syswrite"pop temp 0\n"
    $vmFile.syswrite"pop pointer 1\n"
    $vmFile.syswrite"push temp 0\n"
    $vmFile.syswrite"pop that #{0}\n"
  end
  #writes ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode
end

def ifStatement subroutineKind
  ifNumber =$ifCounter
  $ifCounter = $ifCounter + 1
  myNode=NonTerminalNode.new('ifStatement')
  haveElse =false
  #writes if
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '('
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes expression
  myNode.addNode expression
  #writes ')'
  $vmFile.syswrite "if-goto IF_TRUE#{ifNumber}\n"
  $vmFile.syswrite "goto IF_FALSE#{ifNumber}\n"
  $vmFile.syswrite "label IF_TRUE#{ifNumber}\n"

  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '{'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes statements
  myNode.addNode statements subroutineKind
  #writes '}'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  if ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]==' else ')
    $vmFile.syswrite "goto IF_END#{ifNumber}\n"
    $vmFile.syswrite "label IF_FALSE#{ifNumber}\n"
    #writes else
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    #writes '{'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    #writes statements
    myNode.addNode statements subroutineKind
    #writes '}'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    $vmFile.syswrite "label IF_END#{ifNumber}\n"

  else
    $vmFile.syswrite "label IF_FALSE#{ifNumber}\n"
  end
  return myNode
end

def whileStatement subroutineKind
  myNode = NonTerminalNode.new('whileStatement')
  whileNum = $whileCounter
  $whileCounter = $whileCounter + 1
  #writes while
  $vmFile.syswrite "label WHILE_EXP#{whileNum}\n"

  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '('
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes expression
  myNode.addNode expression
  #writes ')'

  $vmFile.syswrite "not\n"
  $vmFile.syswrite "if-goto WHILE_END#{whileNum}\n"
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes '{'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  #writes statement
  myNode.addNode statements subroutineKind
  #writes '}'

  $vmFile.syswrite "goto WHILE_EXP#{whileNum}\n"
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  $vmFile.syswrite "label WHILE_END#{whileNum}\n"

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
  $vmFile.syswrite "pop temp 0\n"

  return myNode

end


def returnStatement subroutineKind

  myNode = NonTerminalNode.new('returnStatement')

  #writes return

  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  if extract == ';'
    $vmFile.syswrite "push constant 0\n"
    $vmFile.syswrite "return\n"
  end

  #writes expression?
  if ($lines[$lineNumber][($lines[$lineNumber].index('>')+1)..($lines[$lineNumber].index('</')-1)]!=' ; ')
    myNode.addNode expression
    $vmFile.syswrite "return\n"
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
    action = extract
    $lineNumber = $lineNumber+1

    #term
    myNode.addNode term

    if action == '-'
      $vmFile.syswrite "neg\n"
    elsif action == '~'
      $vmFile.syswrite "not\n"
    end

    #doing varName '[' expression ']', there is look ahead
  elsif ($lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)]==' [ ')

    #writes varName
    name = extract
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
    if ($methodScopeSymbolTable.getNumberByName name) != -1
      $vmFile.syswrite "push #{getVmKindBySymbolKind ($methodScopeSymbolTable.getKindByName name)} #{$methodScopeSymbolTable.getNumberByName name}\n"
    else
      $vmFile.syswrite "push #{getVmKindBySymbolKind ($classScopeSymbolTable.getKindByName name)} #{$classScopeSymbolTable.getNumberByName name}\n"
    end
    $vmFile.syswrite "add\n"
    $vmFile.syswrite "pop pointer #{1}\n"
    $vmFile.syswrite "push that #{0}\n"

    #doing subroutineCall
  elsif ([' ( ', ' . '].include? $lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)])

    #subroutineCall
    myNode.addNode subroutineCall myNode

  else

    #writes integerConstant|stringConstant|keywordConstant|varName
    if $keyword.include? extract
      if extract == 'null'
        $vmFile.syswrite "push constant 0\n"
      elsif extract =='true'
        $vmFile.syswrite "push constant 0\n"
        $vmFile.syswrite "not\n"
      elsif extract =='false'
        $vmFile.syswrite "push constant 0\n"
      elsif extract =='this'
        $vmFile.syswrite "push pointer 0\n"
      end
      myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
    elsif $lines[$lineNumber][($lines[$lineNumber].index('<')+1)..($lines[$lineNumber].index('>')-1)] == 'stringConstant'
      myNode.addNode TerminalNode.new('stringConstant', $lines[$lineNumber])
      const = extract
      $vmFile.syswrite "push constant #{const.length}\n"
      $vmFile.syswrite "call String.new 1\n"
      for i in 0..(const.length) -1
        $vmFile.syswrite "push constant #{const[i].ord}\n"
        $vmFile.syswrite "call String.appendChar 2\n"
      end
    elsif extract.to_i.to_s == extract
      number = extract
      myNode.addNode TerminalNode.new('integerConstant', $lines[$lineNumber])
      $vmFile.syswrite "push constant #{number.to_s}\n"
    else
      myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
      #writes the push kind number
      name = extract
      if ($methodScopeSymbolTable.getNumberByName name) != -1
        $vmFile.syswrite "push #{getVmKindBySymbolKind ($methodScopeSymbolTable.getKindByName name)} #{$methodScopeSymbolTable.getNumberByName name}\n"
      else
        $vmFile.syswrite "push #{getVmKindBySymbolKind ($classScopeSymbolTable.getKindByName name)} #{$classScopeSymbolTable.getNumberByName name}\n"
      end

    end
    $lineNumber = $lineNumber+1
  end

  return myNode

end

def subroutineCall(myNode)
  if !myNode
    myNode = NonTerminalNode.new 'subroutineCall'
  end
  if $lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)]==' ( '
    #writes subroutineName
    name = extract
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes ' ( '
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    $vmFile.syswrite "push pointer 0\n"
    #writes expressionList
    myNode.addNode expressionList

    #writes ')'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    $vmFile.syswrite "call #{$file_name}.#{name} #{$argNumber + 1}\n"

  elsif $lines[$lineNumber+1][($lines[$lineNumber + 1].index('>')+1)..($lines[$lineNumber+1].index('</')-1)] == ' . '

    #writes className|varName
    name = extract
    varName = name
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes '.'
    funcPart ='.'
    name += '.'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes subroutineName
    funcPart +=extract
    name+=extract
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes ' ( '
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #check if calling method
    if ($classScopeSymbolTable.getNumberByName varName) != -1 || ($methodScopeSymbolTable.getNumberByName varName) != -1
      if ($methodScopeSymbolTable.getNumberByName varName) != -1
        $vmFile.syswrite "push #{getVmKindBySymbolKind($methodScopeSymbolTable.getKindByName varName)} #{$methodScopeSymbolTable.getNumberByName varName}\n"
      else
        $vmFile.syswrite "push #{getVmKindBySymbolKind($classScopeSymbolTable.getKindByName varName)} #{$classScopeSymbolTable.getNumberByName varName}\n"
      end
    end
    #writes expressionList
    myNode.addNode expressionList

    #writes ')'
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    if ($classScopeSymbolTable.getNumberByName varName) == -1 && ($methodScopeSymbolTable.getNumberByName varName) == -1
      $vmFile.syswrite "call #{name} #{$argNumber}\n"
    else
      if ($methodScopeSymbolTable.getNumberByName varName) != -1
        $vmFile.syswrite "call #{($methodScopeSymbolTable.getTypeByName varName).to_s + funcPart} #{$argNumber + 1}\n"
      else
        $vmFile.syswrite "call #{($classScopeSymbolTable.getTypeByName varName).to_s + funcPart} #{$argNumber + 1}\n"
      end
    end
  end

end

def varDec

  myNode = NonTerminalNode.new('varDec')

  #writes var
  kind = extract
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writes type
  type = extract
  if $keyword.include? extract
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  else
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  end
  $lineNumber = $lineNumber+1

  #writes varName
  name = extract
  myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1
  $localVariablesNum = $localVariablesNum + 1


  #adding to $methodScopeSymbolTable
  $methodScopeSymbolTable.addSymbol name, type, kind
  #doing (','varName)*
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] == ' , '
    #writes ','
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes varName
    name = extract
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    $localVariablesNum = $localVariablesNum + 1
    #adding to $methodScopeSymbolTable
    $methodScopeSymbolTable.addSymbol name, type, kind

  end

  #writing the ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  return myNode
end

def parameterList
  kind = 'argument'

  myNode = NonTerminalNode.new('parameterList')
  if $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] != ' ) '
    type = extract
    if $keyword.include? extract
      myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
    else
      myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    end
    $lineNumber = $lineNumber+1

    name = extract
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    $methodScopeSymbolTable.addSymbol name, type, kind
  end
  #writes until gets to ')'
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] != ' ) '
    #write ','
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #write type
    type = extract
    if $keyword.include? extract
      myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
    else
      myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    end
    $lineNumber = $lineNumber+1

    #writeVarName
    name = extract
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    $methodScopeSymbolTable.addSymbol name, type, kind
  end

  return myNode
end

def classVarDec
  myNode = NonTerminalNode.new('classVarDec')

  #writing the static or field
  kind = extract
  myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #writing the type
  type = extract
  if $keyword.include? extract
    myNode.addNode TerminalNode.new('keyword', $lines[$lineNumber])
  else
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  end
  $lineNumber = $lineNumber+1

  #writing the varName
  name = extract
  myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
  $lineNumber = $lineNumber+1

  #adding to classSymbolTable
  $classScopeSymbolTable.addSymbol name, type, kind

  #doing (','varName)*
  while $lines[$lineNumber][$lines[$lineNumber].index('>')+1..$lines[$lineNumber].index('</')-1] == ' , '
    #writes ','
    myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
    $lineNumber = $lineNumber+1

    #writes varName
    name = extract
    myNode.addNode TerminalNode.new('identifier', $lines[$lineNumber])
    $lineNumber = $lineNumber+1
    $classScopeSymbolTable.addSymbol name, type, kind

  end

  #writing the ';'
  myNode.addNode TerminalNode.new('symbol', $lines[$lineNumber])
  $lineNumber = $lineNumber+1


  return myNode
end

def printXML(myTree, tabs)
  if myTree.is_a? TerminalNode
    $xmlFile.syswrite('  '*tabs+myTree.text)
  elsif myTree.is_a? NonTerminalNode
    $xmlFile.syswrite('  '*tabs+"<"+myTree.type+">\n")
    myTree.itsNodes.each do |i|
      printXML i, tabs+1
    end
    $xmlFile.syswrite('  '*tabs+"</"+myTree.type+">\n")
  end
end

def printNode(node)
  if node.is_a? NonTerminalNode
    if node.type == 'subRoutineDec'

    end
  end
end

def delete_xml
  files = Dir.glob '*.xml'
  for i in 0..(files.length - 1) do
    file_name=files[i]
    File.delete "#{file_name}"
  end
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


for i in 0..files.length - 1 do
  $classScopeSymbolTable = SymbolTable.new
  $methodScopeSymbolTable = SymbolTable.new
  $localVariablesNum = 0
  $argNumber = 0
  $whileCounter = 0
  $ifCounter = 0

  $file_name=files[i][0..files[i].index('T.xml')-1]
  $xmlFile = File.new("#{$file_name}.xml", 'w')
  $vmFile = File.new("#{$file_name}.vm", 'w')
  $lines = File.readlines("#{$file_name}T.xml")
  myTree = start

  puts "$classScopeSymbolTable #{$file_name}:"
  $classScopeSymbolTable.myPrint
  printXML myTree, 0
  $xmlFile.close
end
delete_xml