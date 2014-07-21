var malg_url = 'http://microalg.info/doc.html';

// Préparation du générateur de code basée sur
// http://code.google.com/p/blockly/source/browse/trunk/generators/python.js

Blockly.MicroAlg = new Blockly.Generator('MicroAlg');

Blockly.MicroAlg.addReservedWords(
    '=, =/, <, <=, >, >=, ' +
    'Affecter_a, Afficher, Aide, Bloc, Booleen?, Concatener, ' +
    'Demander, Faire, Faux, Faux?, Initialiser, Nombre, Nombre?, ' +
    'Rien, Si, Tant_que, Texte, Texte?, Type, Vrai, Vrai?');

// La suite, jusqu’au commentaire de fin, n’a pas été modifiée.

Blockly.MicroAlg.ORDER_ATOMIC = 0;            // 0 "" ...
Blockly.MicroAlg.ORDER_COLLECTION = 1;        // tuples, lists, dictionaries
Blockly.MicroAlg.ORDER_STRING_CONVERSION = 1; // `expression...`
Blockly.MicroAlg.ORDER_MEMBER = 2;            // . []
Blockly.MicroAlg.ORDER_FUNCTION_CALL = 2;     // ()
Blockly.MicroAlg.ORDER_EXPONENTIATION = 3;    // **
Blockly.MicroAlg.ORDER_UNARY_SIGN = 4;        // + -
Blockly.MicroAlg.ORDER_BITWISE_NOT = 4;       // ~
Blockly.MicroAlg.ORDER_MULTIPLICATIVE = 5;    // * / // %
Blockly.MicroAlg.ORDER_ADDITIVE = 6;          // + -
Blockly.MicroAlg.ORDER_BITWISE_SHIFT = 7;     // << >>
Blockly.MicroAlg.ORDER_BITWISE_AND = 8;       // &
Blockly.MicroAlg.ORDER_BITWISE_XOR = 9;       // ^
Blockly.MicroAlg.ORDER_BITWISE_OR = 10;       // |
Blockly.MicroAlg.ORDER_RELATIONAL = 11;       // in, not in, is, is not,
                                            //     <, <=, >, >=, <>, !=, ==
Blockly.MicroAlg.ORDER_LOGICAL_NOT = 12;      // not
Blockly.MicroAlg.ORDER_LOGICAL_AND = 13;      // and
Blockly.MicroAlg.ORDER_LOGICAL_OR = 14;       // or
Blockly.MicroAlg.ORDER_CONDITIONAL = 15;      // if else
Blockly.MicroAlg.ORDER_LAMBDA = 16;           // lambda
Blockly.MicroAlg.ORDER_NONE = 99;             // (...)

/**
 * Initialise the database of variable names.
 */
Blockly.MicroAlg.init = function() {
  // Create a dictionary of definitions to be printed before the code.
  Blockly.MicroAlg.definitions_ = Object.create(null);
  // Create a dictionary mapping desired function names in definitions_
  // to actual function names (to avoid collisions with user functions).
  Blockly.MicroAlg.functionNames_ = Object.create(null);

  if (Blockly.Variables) {
    if (!Blockly.MicroAlg.variableDB_) {
      Blockly.MicroAlg.variableDB_ =
          new Blockly.Names(Blockly.MicroAlg.RESERVED_WORDS_);
    } else {
      Blockly.MicroAlg.variableDB_.reset();
    }

    var defvars = [];
    var variables = Blockly.Variables.allVariables();
    for (var x = 0; x < variables.length; x++) {
      defvars[x] = Blockly.MicroAlg.variableDB_.getName(variables[x],
          Blockly.Variables.NAME_TYPE) + ' = None';
    }
    Blockly.MicroAlg.definitions_['variables'] = defvars.join('\n');
  }
};

/**
 * Prepend the generated code with the variable definitions.
 * @param {string} code Generated code.
 * @return {string} Completed code.
 */
Blockly.MicroAlg.finish = function(code) {
  // Convert the definitions dictionary into a list.
  var imports = [];
  var definitions = [];
  for (var name in Blockly.MicroAlg.definitions_) {
    var def = Blockly.MicroAlg.definitions_[name];
    if (def.match(/^(from\s+\S+\s+)?import\s+\S+/)) {
      imports.push(def);
    } else {
      definitions.push(def);
    }
  }
  var allDefs = imports.join('\n') + '\n\n' + definitions.join('\n\n');
  return allDefs.replace(/\n\n+/g, '\n\n').replace(/\n*$/, '\n\n\n') + code;
};

/**
 * Naked values are top-level blocks with outputs that aren't plugged into
 * anything.
 * @param {string} line Line of generated code.
 * @return {string} Legal line of code.
 */
Blockly.MicroAlg.scrubNakedValue = function(line) {
  return line + '\n';
};

/**
 * Encode a string as a properly escaped MicroAlg string, complete with quotes.
 * @param {string} string Text to encode.
 * @return {string} MicroAlg string.
 * @private
 */
Blockly.MicroAlg.quote_ = function(string) {
  // TODO: This is a quick hack.  Replace with goog.string.quote
  string = string.replace(/\\/g, '\\\\')
                 .replace(/\n/g, '\\\n')
                 .replace(/\%/g, '\\%')
                 .replace(/'/g, '\\\'');
  return '"' + string + '"';
};

/**
 * Common tasks for generating MicroAlg from blocks.
 * Handles comments for the specified block and any connected value blocks.
 * Calls any statements following this block.
 * @param {!Blockly.Block} block The current block.
 * @param {string} code The MicroAlg code created for this block.
 * @return {string} MicroAlg code with comments and subsequent blocks added.
 * @private
 */
Blockly.MicroAlg.scrub_ = function(block, code) {
  var commentCode = '';
  // Only collect comments for blocks that aren't inline.
  if (!block.outputConnection || !block.outputConnection.targetConnection) {
    // Collect comment for this block.
    var comment = block.getCommentText();
    if (comment) {
      commentCode += this.prefixLines(comment, '# ') + '\n';
    }
    // Collect comments for all value arguments.
    // Don't collect comments for nested statements.
    for (var x = 0; x < block.inputList.length; x++) {
      if (block.inputList[x].type == Blockly.INPUT_VALUE) {
        var childBlock = block.inputList[x].connection.targetBlock();
        if (childBlock) {
          var comment = this.allNestedComments(childBlock);
          if (comment) {
            commentCode += this.prefixLines(comment, '# ');
          }
        }
      }
    }
  }
  var nextBlock = block.nextConnection && block.nextConnection.targetBlock();
  var nextCode = this.blockToCode(nextBlock);
  return commentCode + code + nextCode;
};

// Commentaire de fin (de section non modifiée).

// Blocs et générateurs (groupés, pas comme dans l’original).
// Basés sur:
// http://code.google.com/p/blockly/source/browse/trunk/blocks
// http://code.google.com/p/blockly/source/browse/trunk/generators/python

// Bloc texte
Blockly.Blocks['texte'] = {
  init: function() {
    this.setHelpUrl(malg_url);
    this.setColour(160);
    this.appendDummyInput()
        .appendField(this.newQuote_(true))
        .appendField(new Blockly.FieldTextInput(''), 'TEXT')
        .appendField(this.newQuote_(false));
    this.setOutput(true, 'String');
    this.setTooltip('Texte');
  },
  newQuote_: function(open) {
    if (open == Blockly.RTL) {
      var file = 'quote1.png';
    } else {
      var file = 'quote0.png';
    }
    return new Blockly.FieldImage(Blockly.pathToBlockly + 'media/' + file,
                                  12, 12, '"');
  }
};

// Gen texte
Blockly.MicroAlg['texte'] = function(block) {
  // Text value.
  var code = Blockly.MicroAlg.quote_(block.getFieldValue('TEXT'));
  return [code, 0];
};

// Bloc concatener
Blockly.Blocks['concatener'] = {
  init: function() {
    this.setHelpUrl(malg_url);
    this.setColour(160);
    this.appendValueInput('ADD0')
        .appendField('Concaténer');
    this.appendValueInput('ADD1');
    this.setOutput(true, 'String');
    this.setMutator(new Blockly.Mutator(['text_create_join_item']));
    this.setTooltip('Mettre des textes bout à bout.');
    this.itemCount_ = 2;
  },
  mutationToDom: function() {
    var container = document.createElement('mutation');
    container.setAttribute('items', this.itemCount_);
    return container;
  },
  domToMutation: function(xmlElement) {
    for (var x = 0; x < this.itemCount_; x++) {
      this.removeInput('ADD' + x);
    }
    this.itemCount_ = parseInt(xmlElement.getAttribute('items'), 10);
    for (var x = 0; x < this.itemCount_; x++) {
      var input = this.appendValueInput('ADD' + x);
      if (x == 0) {
        input.appendField('Concaténer');
      }
    }
    if (this.itemCount_ == 0) {
      this.appendDummyInput('EMPTY')
          .appendField(new Blockly.FieldImage(Blockly.pathToBlockly +
          'media/quote0.png', 12, 12, '"'))
          .appendField(new Blockly.FieldImage(Blockly.pathToBlockly +
          'media/quote1.png', 12, 12, '"'));
    }
  },
  decompose: function(workspace) {
    var containerBlock = Blockly.Block.obtain(workspace,
                                           'text_create_join_container');
    containerBlock.initSvg();
    var connection = containerBlock.getInput('STACK').connection;
    for (var x = 0; x < this.itemCount_; x++) {
      var itemBlock = Blockly.Block.obtain(workspace, 'text_create_join_item');
      itemBlock.initSvg();
      connection.connect(itemBlock.previousConnection);
      connection = itemBlock.nextConnection;
    }
    return containerBlock;
  },
  compose: function(containerBlock) {
    // Disconnect all input blocks and remove all inputs.
    if (this.itemCount_ == 0) {
      this.removeInput('EMPTY');
    } else {
      for (var x = this.itemCount_ - 1; x >= 0; x--) {
        this.removeInput('ADD' + x);
      }
    }
    this.itemCount_ = 0;
    // Rebuild the block's inputs.
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    while (itemBlock) {
      var input = this.appendValueInput('ADD' + this.itemCount_);
      if (this.itemCount_ == 0) {
        input.appendField('Concaténer');
      }
      // Reconnect any child blocks.
      if (itemBlock.valueConnection_) {
        input.connection.connect(itemBlock.valueConnection_);
      }
      this.itemCount_++;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
    }
    if (this.itemCount_ == 0) {
      this.appendDummyInput('EMPTY')
          .appendField(new Blockly.FieldImage(Blockly.pathToBlockly +
          'media/quote0.png', 12, 12, '"'))
          .appendField(new Blockly.FieldImage(Blockly.pathToBlockly +
          'media/quote1.png', 12, 12, '"'));
    }
  },
  saveConnections: function(containerBlock) {
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    var x = 0;
    while (itemBlock) {
      var input = this.getInput('ADD' + x);
      itemBlock.valueConnection_ = input && input.connection.targetConnection;
      x++;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
    }
  }
};

// Conteneur pour le mutator de concatener
Blockly.Blocks['text_create_join_container'] = {
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
        .appendField('Nbre de paramètres');
    this.appendStatementInput('STACK');
    this.setTooltip('Mettre ici le bon nombre de paramètres.');
    this.contextMenu = false;
  }
};

// Élément pour le mutator de concatener
Blockly.Blocks['text_create_join_item'] = {
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
        .appendField('un paramètre');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('À placer autant de fois que nécessaire.');
    this.contextMenu = false;
  }
};

// Gen concatener
Blockly.MicroAlg['concatener'] = function(block) {
  var cmd = 'Concatener';
  var code;
  if (block.itemCount_ == 0) {
    return ['(' + cmd + ')', Blockly.MicroAlg.ORDER_ATOMIC];
  } else if (block.itemCount_ == 1) {
    var argument0 = Blockly.MicroAlg.valueToCode(block, 'ADD0', Blockly.MicroAlg.ORDER_NONE) || '""';
    code = '(' + cmd + ' ' + argument0 + ')';
    return [code, Blockly.MicroAlg.ORDER_FUNCTION_CALL];
  } else {
    var args = [];
    for (var n = 0; n < block.itemCount_; n++) {
      args[n] = Blockly.MicroAlg.valueToCode(block, 'ADD' + n, Blockly.MicroAlg.ORDER_NONE) || '""';
    }
    code = '(' + cmd + ' ' + args.join(' ') + ')';
    return [code, Blockly.MicroAlg.ORDER_FUNCTION_CALL];
  }
};

// Bloc afficher
Blockly.Blocks['afficher'] = {
  init: function() {
    this.setHelpUrl(malg_url);
    this.setColour(160);
    this.interpolateMsg('Afficher %1',
                        ['VALUE', null, Blockly.ALIGN_RIGHT],
                        Blockly.ALIGN_RIGHT);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Afficher une valeur à l’utilisateur.');
  }
};

// Gen afficher
Blockly.MicroAlg['afficher'] = function(block) {
  var argument0 = Blockly.MicroAlg.valueToCode(block, 'VALUE', Blockly.MicroAlg.ORDER_NONE) || '';
  return '(Afficher ' + argument0 + ')\n';
};

// Bloc demander
Blockly.Blocks['demander'] = {
  init: function() {
    this.setHelpUrl(malg_url);
    this.setColour(160);
    this.appendDummyInput()
        .appendField('Demander');
    this.setOutput(true, 'String');
    this.setTooltip('Demander une valeur à l’utilisateur.');
  }
};

// Gen demander
Blockly.MicroAlg['demander'] = function(block) {
  return ['(Demander)', Blockly.MicroAlg.ORDER_ATOMIC];
};
