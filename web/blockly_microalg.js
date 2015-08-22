var malg_url = 'http://microalg.info/doc.html';
var colour = 160;

// Un extrait des messages originaux:
// http://code.google.com/p/blockly/source/browse/trunk/msg/js/fr.js

Blockly.Msg.ADD_COMMENT = "Ajouter un commentaire";
Blockly.Msg.AUTH = "Veuillez autoriser cette application à permettre la sauvegarde de votre travail et à l’autoriser de le partager avec vous.";
Blockly.Msg.CHANGE_VALUE_TITLE = "Modifier la valeur :";
Blockly.Msg.CHAT = "Discuter avec votre collaborateur en tapant dans cette zone !";
Blockly.Msg.COLLAPSE_ALL = "Réduire les blocs";
Blockly.Msg.COLLAPSE_BLOCK = "Réduire le bloc";
Blockly.Msg.DELETE_BLOCK = "Supprimer le bloc";
Blockly.Msg.DELETE_X_BLOCKS = "Supprimer %1 blocs";
Blockly.Msg.DISABLE_BLOCK = "Désactiver le bloc";
Blockly.Msg.DUPLICATE_BLOCK = "Dupliquer";
Blockly.Msg.ENABLE_BLOCK = "Activer le bloc";
Blockly.Msg.EXPAND_ALL = "Développer les blocs";
Blockly.Msg.EXPAND_BLOCK = "Développer le bloc";
Blockly.Msg.EXTERNAL_INPUTS = "Entrées externes";
Blockly.Msg.HELP = "Aide";
Blockly.Msg.INLINE_INPUTS = "Entrées en ligne";
Blockly.Msg.NEW_VARIABLE = "Nouvelle variable…";
Blockly.Msg.NEW_VARIABLE_TITLE = "Nom de la nouvelle variable :";
Blockly.Msg.REMOVE_COMMENT = "Supprimer un commentaire";
Blockly.Msg.RENAME_VARIABLE = "Renommer la variable…";
Blockly.Msg.RENAME_VARIABLE_TITLE = "Renommer toutes les variables '%1' en :";

// Préparation du générateur de code basée sur
// http://code.google.com/p/blockly/source/browse/trunk/generators/python.js

Blockly.MicroAlg = new Blockly.Generator('MicroAlg');
Blockly.MicroAlg.INDENT = '  ';
Blockly.MicroAlg.addReservedWords(
    'RAZ, AV, BC, LC, TD, TG, Cercle, Contour, Ellipse, Epaisseur, ' +
    'Rectangle, Remplissage, Segment, Triangle, ' +
    'Affecter_a, Afficher, Aide, Ajouter_a, Alors, Concatener, ' +
    'Declarer', 'Definir, Demander, Demander_un_nombre, ' +
    'En_position, Entier@, Et, Exemples_de, ' +
    'Faire, Faux, Initialiser@, ' +
    'Liste, Longueur, Millisecondes, ' +
    'Nieme, Nieme@, Nombre, Non, Ou, ' +
    'Queue, Retirer_de, Retourner, Rien, Si, Sinon, ' +
    'Tant_que, Tester, Tete, Texte, Type, ' +
    'Vide?, Vrai');

// La suite, jusqu’au commentaire de fin, n’a pas été modifiée.

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
  string = string
                 // Échapper les guillemets, sauf le premier et le dernier
                 // (il faut qu’il y ait un caractère avant et un après).
                 .replace(/(.)"(.)/g, '$1\\"$2')
          ;
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

// https://groups.google.com/forum/#!searchin/blockly/indentation/blockly/siVJ3OQQpQU/lYf6jqdTERMJ
Blockly.Generator.prototype.prefixLines = function(text, prefix) {
    // Original was:
    // return prefix + text.replace(/\n(.)/g, '\n' + prefix + '$1');
    var splitted = text.split('\n');
    if (splitted.length == 1) return prefix + text;
    var indented = splitted.map(function (line) {
        // Désactivation de l’indentation.
        if (line.indexOf(' Alors') == 0) return line;
        if (line.indexOf(' Sinon') == 0) return line;
        if (line.indexOf(')') == 0) return line;
        return prefix + line;
    });
    return indented.join('\n');
};

// Blocs et générateurs (groupés, pas comme dans l’original).
// Basés sur:
// http://code.google.com/p/blockly/source/browse/trunk/blocks
// http://code.google.com/p/blockly/source/browse/trunk/generators/python

// Bloc Variable
// https://github.com/google/blockly/blob/master/blocks/variables.js
Blockly.Blocks['variable'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#variables');
    this.setColour(colour);
    this.appendDummyInput()
    .appendField(new Blockly.FieldVariable('ma_variable'), 'VAR');
    this.setOutput(true);
    this.setTooltip("Donne la valeur de la variable.");
    this.contextMenuMsg_ = Blockly.Msg.VARIABLES_GET_CREATE_SET;
    this.contextMenuType_ = 'variables_set';
  },
  getVars: function() {
    return [this.getFieldValue('VAR')];
  },
  renameVar: function(oldName, newName) {
    if (Blockly.Names.equals(oldName, this.getFieldValue('VAR'))) {
      this.setFieldValue(newName, 'VAR');
    }
  },
  customContextMenu: function(options) {
    var option = {enabled: true};
    var name = this.getFieldValue('VAR');
    option.text = name;
    var xmlField = goog.dom.createDom('field', null, name);
    xmlField.setAttribute('name', 'VAR');
    var xmlBlock = goog.dom.createDom('block', null, xmlField);
    xmlBlock.setAttribute('type', this.contextMenuType_);
    option.callback = Blockly.ContextMenu.callbackFactory(this, xmlBlock);
    options.push(option);
  }
};

// Gen Variable
// https://github.com/google/blockly/blob/master/generators/javascript/variables.js
Blockly.MicroAlg['variable'] = function(block) {
  return block.getFieldValue('VAR');
};

// Conteneur pour le mutator du nombre de paramètres
Blockly.Blocks['nb_params_container'] = {
  init: function() {
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Nbre de paramètres');
    this.appendStatementInput('STACK');
    this.setTooltip('Mettre ici le bon nombre de paramètres.');
    this.contextMenu = false;
  }
};

// Élément pour le mutator du nombre de paramètres
Blockly.Blocks['nb_params_item'] = {
  init: function() {
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('un paramètre');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('À placer autant de fois que nécessaire.');
    this.contextMenu = false;
  }
};

// Bloc Programme
Blockly.Blocks['programme'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#blocprogramme');
    this.setColour(colour);
    this.appendStatementInput('VALUE')
        .appendField('Programme');
    this.setPreviousStatement(false);
    this.setNextStatement(false);
    this.setTooltip('Contient le programme.');
    this.setDeletable(false);
  }
};

// Gen Programme
Blockly.MicroAlg['programme'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  // Le slice neutralise l’indentation,
  // et on passe à la ligne entre les ) et les (.
  var src = arg.substring(2).replace(/\)\(/gm, ')\n(');
  // Ensuite on marque le début et la fin histoire de ne garder que le code des
  // blocs situés dans Programme.
  return '««««««««««' + src + '»»»»»»»»»»';
};

// Bloc Commentaire
Blockly.Blocks['commentaire'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-!!!');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('!!!')
        .appendField(this.newQuote_(true))
        .appendField(new Blockly.FieldTextInput(''), 'COMZ')
        .appendField(this.newQuote_(false));
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Commentaire. Aucune action n’est réalisée.');
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

// Gen Commentaire
Blockly.MicroAlg['commentaire'] = function(block) {
  var arg = Blockly.MicroAlg.quote_(block.getFieldValue('COMZ'));
  return '(!!! ' + arg + ')';
};

// Bloc Affecter_a
// https://github.com/google/blockly/blob/master/blocks/variables.js
Blockly.Blocks['affecter_a'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Affecter_a');
    this.setColour(colour);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Affecter une valeur à une variable.');
    this.interpolateMsg(
      'Affecter_a' + ' %1 ' + ' %2',
      ['VAR', new Blockly.FieldVariable("ma_variable")],
      ['VALUE', null],
      Blockly.ALIGN_RIGHT);
    this.setInputsInline(false);
    this.contextMenuMsg_ = "Créer truc"; // ???
    this.contextMenuType_ = 'variable';
  },
  getVars: function() {
    return [this.getFieldValue('VAR')];
  },
  renameVar: function(oldName, newName) {
    if (Blockly.Names.equals(oldName, this.getFieldValue('VAR'))) {
        this.setFieldValue(newName, 'VAR');
    }
  },
  customContextMenu: Blockly.Blocks['variable'].customContextMenu
};

// Gen Affecter_a
// https://github.com/google/blockly/blob/master/generators/javascript/variables.js
Blockly.MicroAlg['affecter_a'] = function(block) {
  var value = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  var value_cleaned = value.toString().trim();
  return '(Affecter_a ' + this.getFieldValue('VAR') + ' ' + value_cleaned + ')';
};

// Bloc Afficher
Blockly.Blocks['afficher'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Afficher');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Afficher');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Afficher une valeur à l’utilisateur.');
  }
};

// Gen Afficher
Blockly.MicroAlg['afficher'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Afficher)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Afficher ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Afficher\n' + arg + '\n)';
  }
};

// Bloc Aide
// Gen Aide

// Bloc Concatener
Blockly.Blocks['concatener'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Concatener');
    this.setColour(colour);
    this.appendValueInput('ITEM0')
        .appendField('Concaténer');
    this.appendValueInput('ITEM1');
    this.setOutput(true, 'String');
    this.setMutator(new Blockly.Mutator(['nb_params_item']));
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
      this.removeInput('ITEM' + x);
    }
    this.itemCount_ = parseInt(xmlElement.getAttribute('items'), 10);
    for (var x = 0; x < this.itemCount_; x++) {
      var input = this.appendValueInput('ITEM' + x);
      if (x == 0) {
        input.appendField('Concaténer');
      }
    }
    if (this.itemCount_ == 0) {
      this.appendDummyInput('EMPTY')
          .appendField('Concaténer');
    }
  },
  decompose: function(workspace) {
    var containerBlock = Blockly.Block.obtain(workspace, 'nb_params_container');
    containerBlock.initSvg();
    var connection = containerBlock.getInput('STACK').connection;
    for (var x = 0; x < this.itemCount_; x++) {
      var itemBlock = Blockly.Block.obtain(workspace, 'nb_params_item');
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
        this.removeInput('ITEM' + x);
      }
    }
    this.itemCount_ = 0;
    // Rebuild the block's inputs.
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    while (itemBlock) {
      var input = this.appendValueInput('ITEM' + this.itemCount_);
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
          .appendField('Concaténer');
    }
  },
  saveConnections: function(containerBlock) {
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    var x = 0;
    while (itemBlock) {
      var input = this.getInput('ITEM' + x);
      itemBlock.valueConnection_ = input && input.connection.targetConnection;
      x++;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
    }
  }
};

// Gen Concatener
Blockly.MicroAlg['concatener'] = function(block) {
  var cmd = 'Concatener';
  var code;
  if (block.itemCount_ == 0) {
    code ='(' + cmd + ')';
  } else if (block.itemCount_ == 1) {
    var argument0 = Blockly.MicroAlg.statementToCode(block, 'ITEM0') || '""';
    code = '(' + cmd + ' ' + argument0 + ')';
  } else {
    var args = [];
    for (var n = 0; n < block.itemCount_; n++) {
      args[n] = Blockly.MicroAlg.statementToCode(block, 'ITEM' + n) ||
             Blockly.MicroAlg.INDENT + '""';
    }
    code = '(' + cmd + '\n' + args.join('\n') + '\n)';
  }
  return code;
};

// Bloc Declarer
// https://github.com/google/blockly/blob/master/blocks/variables.js
Blockly.Blocks['declarer'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Declarer');
    this.setColour(colour);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Déclarer une variable avec un type.');
    this.interpolateMsg(
      'Declarer' + ' %1 ' + 'De_type' + '%2',
      ['VAR', new Blockly.FieldVariable("ma_variable")],
      ['TYPE', null],
      Blockly.ALIGN_RIGHT);
    this.setInputsInline(false);
    this.contextMenuMsg_ = "Créer truc"; // ???
    this.contextMenuType_ = 'variable';
  },
  getVars: function() {
    return [this.getFieldValue('VAR')];
  },
  renameVar: function(oldName, newName) {
    if (Blockly.Names.equals(oldName, this.getFieldValue('VAR'))) {
        this.setFieldValue(newName, 'VAR');
    }
  },
  customContextMenu: Blockly.Blocks['variable'].customContextMenu
};

// Gen Declarer
// https://github.com/google/blockly/blob/master/generators/javascript/variables.js
Blockly.MicroAlg['declarer'] = function(block) {
  var type = Blockly.MicroAlg.statementToCode(block, 'TYPE') || '';
  var type_cleaned = type.toString().trim();
  return '(Declarer ' + this.getFieldValue('VAR') + ' De_type ' + type_cleaned + ')';
};

// Bloc Demander
Blockly.Blocks['demander'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Demander');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Demander');
    this.setOutput(true, 'String');
    this.setTooltip('Demander une valeur à l’utilisateur.');
  }
};

// Gen Demander
Blockly.MicroAlg['demander'] = function(block) {
  return '(Demander)';
};

// Bloc Demander un nombre
Blockly.Blocks['demander_un_nombre'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Demander_un_nombre');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Demander un nombre');
    this.setOutput(true, 'Number');
    this.setTooltip('Demander un nombre à l’utilisateur.');
  }
};

// Gen Demander un nombre
Blockly.MicroAlg['demander_un_nombre'] = function(block) {
  return '(Demander_un_nombre)';
};

// Bloc Entier@
Blockly.Blocks['entier_pseudo_aleatoire'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Entier@');
    this.setColour(colour);
    this.appendValueInput('MIN')
        .setCheck('Number')
        .appendField('Entier@');
    this.appendValueInput('MAX')
        .setCheck('Number');
    this.setInputsInline(true);
    this.setOutput(true, 'Number');
    this.setTooltip('Nombre pseudo-aléatoire entre les valeurs fournies.');
  }
};

// Gen Entier@
Blockly.MicroAlg['entier_pseudo_aleatoire'] = function(block) {
  var min = Blockly.MicroAlg.statementToCode(block, 'MIN') || '';
  var max = Blockly.MicroAlg.statementToCode(block, 'MAX') || '';
  if (min + max === '') return '(Entier@)';
  var num_lines = (min + max).split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Entier@ ' + min.substring(Blockly.MicroAlg.INDENT.length) +
                   ' ' + max.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Entier@\n' + min + '\n' + max + '\n)';
  }
};

// Bloc Et
Blockly.Blocks['et'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Et');
    this.setColour(colour);
    this.appendValueInput('BOOL0')
        .appendField('Et');
    this.appendValueInput('BOOL1');
    this.setOutput(true, 'Boolean');
    this.setMutator(new Blockly.Mutator(['nb_params_item']));
    this.setTooltip('Retourne Vrai si tous les arguments sont vrais.');
    this.itemCount_ = 2;
  },
  mutationToDom: function() {
    var container = document.createElement('mutation');
    container.setAttribute('items', this.itemCount_);
    return container;
  },
  domToMutation: function(xmlElement) {
    for (var x = 0; x < this.itemCount_; x++) {
      this.removeInput('BOOL' + x);
    }
    this.itemCount_ = parseInt(xmlElement.getAttribute('items'), 10);
    for (var x = 0; x < this.itemCount_; x++) {
      var input = this.appendValueInput('BOOL' + x);
      if (x == 0) {
        input.appendField('Et');
      }
    }
    if (this.itemCount_ == 0) {
      this.appendDummyInput('EMPTY')
          .appendField('Et');
    }
  },
  decompose: function(workspace) {
    var containerBlock = Blockly.Block.obtain(workspace, 'nb_params_container');
    containerBlock.initSvg();
    var connection = containerBlock.getInput('STACK').connection;
    for (var x = 0; x < this.itemCount_; x++) {
      var itemBlock = Blockly.Block.obtain(workspace, 'nb_params_item');
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
        this.removeInput('BOOL' + x);
      }
    }
    this.itemCount_ = 0;
    // Rebuild the block's inputs.
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    while (itemBlock) {
      var input = this.appendValueInput('BOOL' + this.itemCount_);
      if (this.itemCount_ == 0) {
        input.appendField('Et');
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
          .appendField('Et');
    }
  },
  saveConnections: function(containerBlock) {
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    var x = 0;
    while (itemBlock) {
      var input = this.getInput('BOOL' + x);
      itemBlock.valueConnection_ = input && input.connection.targetConnection;
      x++;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
    }
  }
};

// Gen Et
Blockly.MicroAlg['et'] = function(block) {
  var cmd = 'Et';
  var code;
  if (block.itemCount_ == 0) {
    code ='(' + cmd + ')';
  } else if (block.itemCount_ == 1) {
    var argument0 = Blockly.MicroAlg.statementToCode(block, 'BOOL0') || 'Rien';
    code = '(' + cmd + ' ' + argument0 + ')';
  } else {
    var args = [];
    for (var n = 0; n < block.itemCount_; n++) {
      args[n] = Blockly.MicroAlg.statementToCode(block, 'BOOL' + n) ||
             Blockly.MicroAlg.INDENT + 'Rien';
    }
    code = '(' + cmd + '\n' + args.join('\n') + '\n)';
  }
  return code;
};

// Bloc Faire
Blockly.Blocks['faire'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Faire');
    this.setColour(colour);
    this.appendStatementInput('INSTR')
        .appendField('Faire');
    this.appendValueInput('COND')
        //.setCheck('Boolean')
        .appendField('Tant_que');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Structure itérative');
    },
};

// Gen Faire
Blockly.MicroAlg['faire'] = function(block) {
    var instr = Blockly.MicroAlg.statementToCode(block, 'INSTR') || '';
    var cond = Blockly.MicroAlg.statementToCode(block, 'COND') || '';
    instr = instr.replace(/\)\(/gm, ')\n' + Blockly.MicroAlg.INDENT + '(');
    var code = '(Faire \n' + instr +
               '\nTant_que ' + cond.trim();
    code += '\n)'
    return code;
};

// Bloc Initialiser@
Blockly.Blocks['initialiser_pseudo_aleatoire'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Initialiser@');
    this.setColour(colour);
    this.appendValueInput('ETAT')
        .setCheck('Number')
        .appendField('Initialiser@');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Initialiser la séquence des nombres pseudo-aléatoire.');
  }
};

// Gen Initialiser@
Blockly.MicroAlg['initialiser_pseudo_aleatoire'] = function(block) {
  var etat = Blockly.MicroAlg.statementToCode(block, 'ETAT') || '';
  return '(Initialiser@ ' + etat.trim() + ')';
};

// Bloc Liste
Blockly.Blocks['liste'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Liste');
    this.setColour(colour);
    this.appendValueInput('ITEM0')
        .appendField('Liste');
    this.appendValueInput('ITEM1');
    this.setInputsInline(true);
    this.setOutput(true);
    this.setMutator(new Blockly.Mutator(['nb_params_item']));
    this.setTooltip('Construire une liste.');
    this.itemCount_ = 2;
  },
  mutationToDom: function() {
    var container = document.createElement('mutation');
    container.setAttribute('items', this.itemCount_);
    return container;
  },
  domToMutation: function(xmlElement) {
    for (var x = 0; x < this.itemCount_; x++) {
      this.removeInput('ITEM' + x);
    }
    this.itemCount_ = parseInt(xmlElement.getAttribute('items'), 10);
    for (var x = 0; x < this.itemCount_; x++) {
      var input = this.appendValueInput('ITEM' + x);
      if (x == 0) {
        input.appendField('Liste');
      }
    }
    if (this.itemCount_ == 0) {
      this.appendDummyInput('EMPTY')
          .appendField('Liste');
    }
  },
  decompose: function(workspace) {
    var containerBlock = Blockly.Block.obtain(workspace, 'nb_params_container');
    containerBlock.initSvg();
    var connection = containerBlock.getInput('STACK').connection;
    for (var x = 0; x < this.itemCount_; x++) {
      var itemBlock = Blockly.Block.obtain(workspace, 'nb_params_item');
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
        this.removeInput('ITEM' + x);
      }
    }
    this.itemCount_ = 0;
    // Rebuild the block's inputs.
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    while (itemBlock) {
      var input = this.appendValueInput('ITEM' + this.itemCount_);
      if (this.itemCount_ == 0) {
        input.appendField('Liste');
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
          .appendField('Liste');
    }
  },
  saveConnections: function(containerBlock) {
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    var x = 0;
    while (itemBlock) {
      var input = this.getInput('ITEM' + x);
      itemBlock.valueConnection_ = input && input.connection.targetConnection;
      x++;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
    }
  }
};

// Gen Liste
Blockly.MicroAlg['liste'] = function(block) {
  var cmd = 'Liste';
  var code;
  if (block.itemCount_ == 0) {
    code ='(' + cmd + ')';
  } else if (block.itemCount_ == 1) {
    var argument0 = Blockly.MicroAlg.statementToCode(block, 'ITEM0') || '""';
    code = '(' + cmd + ' ' + argument0 + ')';
  } else {
    var args = [];
    for (var n = 0; n < block.itemCount_; n++) {
      args[n] = Blockly.MicroAlg.statementToCode(block, 'ITEM' + n) ||
             Blockly.MicroAlg.INDENT + '""';
    }
    code = '(' + cmd + '\n' + args.join('\n') + '\n)';
  }
  return code;
};

// Bloc Longueur
Blockly.Blocks['longueur'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Longueur');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Longueur');
    this.setOutput(true, 'Number');
    this.setTooltip('Retourne la longueur du texte ou de la liste.');
  }
};

// Gen Longueur
Blockly.MicroAlg['longueur'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Longueur)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Longueur ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Longueur\n' + arg + '\n)';
  }
};

// Bloc Millisecondes
Blockly.Blocks['millisecondes'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Millisecondes');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Millisecondes');
    this.setOutput(true, 'Number');
    this.setTooltip('Nombre de millisecondes écoulées depuis le début du programme.');
  }
};

// Gen Millisecondes
Blockly.MicroAlg['millisecondes'] = function(block) {
  return '(Millisecondes)';
};

// Bloc Nieme
Blockly.Blocks['nieme'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Nieme');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Nieme');
    this.appendValueInput('INDEX')
        .setCheck('Number')
    this.setOutput(true);
    this.setTooltip('Retourne un certain élément du texte ou de la liste.');
  }
};

// Gen Nieme
Blockly.MicroAlg['nieme'] = function(block) {
  var val = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  var idx = Blockly.MicroAlg.statementToCode(block, 'INDEX') || '';
  if (val === '' && idx === '') return '(Nieme)';
  var num_lines_val = val.split('\n').length;
  var num_lines_idx = idx.split('\n').length;
  if (num_lines_val == 1 && num_lines_idx == 1) {
    // Prevent indentation if we only have one line.
    return '(Nieme ' + val.substring(Blockly.MicroAlg.INDENT.length) +
                 ' ' + idx.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Nieme\n' + val + '\n' + idx + '\n)';
  }
};

// Bloc Nieme@
Blockly.Blocks['nieme@'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Nieme@');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Nieme@');
    this.setOutput(true);
    this.setTooltip('Retourne un élément du texte ou de la liste au harard.');
  }
};

// Gen Nieme@
Blockly.MicroAlg['nieme@'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Nieme@)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Nieme@ ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Nieme@\n' + arg + '\n)';
  }
};

// Bloc Nombre
Blockly.Blocks['nombre'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Nombre');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Nombre');
    this.setOutput(true, 'Number');
    this.setTooltip('Convertir une valeur en nombre.');
  }
};

// Gen Nombre
Blockly.MicroAlg['nombre'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Nombre)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Nombre ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Nombre\n' + arg + '\n)';
  }
};

// Bloc Non
Blockly.Blocks['non'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Non');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Non');
    this.setOutput(true, 'Boolean');
    this.setTooltip('Retourne la valeur contraire du booléen.');
  }
};

// Gen Non
Blockly.MicroAlg['non'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Non)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Non ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Non\n' + arg + '\n)';
  }
};

// Bloc Ou
Blockly.Blocks['ou'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Ou');
    this.setColour(colour);
    this.appendValueInput('BOOL0')
        .appendField('Ou');
    this.appendValueInput('BOOL1');
    this.setOutput(true, 'Boolean');
    this.setMutator(new Blockly.Mutator(['nb_params_item']));
    this.setTooltip('Retourne Vrai si tous les arguments sont vrais.');
    this.itemCount_ = 2;
  },
  mutationToDom: function() {
    var container = document.createElement('mutation');
    container.setAttribute('items', this.itemCount_);
    return container;
  },
  domToMutation: function(xmlElement) {
    for (var x = 0; x < this.itemCount_; x++) {
      this.removeInput('BOOL' + x);
    }
    this.itemCount_ = parseInt(xmlElement.getAttribute('items'), 10);
    for (var x = 0; x < this.itemCount_; x++) {
      var input = this.appendValueInput('BOOL' + x);
      if (x == 0) {
        input.appendField('Ou');
      }
    }
    if (this.itemCount_ == 0) {
      this.appendDummyInput('EMPTY')
          .appendField('Ou');
    }
  },
  decompose: function(workspace) {
    var containerBlock = Blockly.Block.obtain(workspace, 'nb_params_container');
    containerBlock.initSvg();
    var connection = containerBlock.getInput('STACK').connection;
    for (var x = 0; x < this.itemCount_; x++) {
      var itemBlock = Blockly.Block.obtain(workspace, 'nb_params_item');
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
        this.removeInput('BOOL' + x);
      }
    }
    this.itemCount_ = 0;
    // Rebuild the block's inputs.
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    while (itemBlock) {
      var input = this.appendValueInput('BOOL' + this.itemCount_);
      if (this.itemCount_ == 0) {
        input.appendField('Ou');
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
          .appendField('Ou');
    }
  },
  saveConnections: function(containerBlock) {
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    var x = 0;
    while (itemBlock) {
      var input = this.getInput('BOOL' + x);
      itemBlock.valueConnection_ = input && input.connection.targetConnection;
      x++;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
    }
  }
};

// Gen Ou
Blockly.MicroAlg['ou'] = function(block) {
  var cmd = 'Ou';
  var code;
  if (block.itemCount_ == 0) {
    code ='(' + cmd + ')';
  } else if (block.itemCount_ == 1) {
    var argument0 = Blockly.MicroAlg.statementToCode(block, 'BOOL0') || 'Rien';
    code = '(' + cmd + ' ' + argument0 + ')';
  } else {
    var args = [];
    for (var n = 0; n < block.itemCount_; n++) {
      args[n] = Blockly.MicroAlg.statementToCode(block, 'BOOL' + n) ||
             Blockly.MicroAlg.INDENT + 'Rien';
    }
    code = '(' + cmd + '\n' + args.join('\n') + '\n)';
  }
  return code;
};

// Bloc Queue
Blockly.Blocks['queue'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Queue');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Queue');
    this.setOutput(true);
    this.setTooltip('Retourne tout sauf la tête (c-à-d sauf le premier élément).');
  }
};

// Gen Queue
Blockly.MicroAlg['queue'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Queue)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Queue ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Queue\n' + arg + '\n)';
  }
};

// Bloc Si
// https://github.com/google/blockly/blob/master/blocks/logic.js#L34
Blockly.Blocks['si'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Si');
    this.setColour(colour);
    this.appendValueInput('COND')
        .setCheck('Boolean')
        .appendField('Si');
    this.appendStatementInput('ALORS')
        .appendField('Alors');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setMutator(new Blockly.Mutator(['si_alors_sinon_sinon']));
    this.setTooltip('Structure conditionnelle');
    this.elseCount_ = 0;
    },
    mutationToDom: function() {
        if (!this.elseCount_) {
            return null;
        }
        var container = document.createElement('mutation');
        if (this.elseCount_) {
            container.setAttribute('sinon', 1);
        }
        return container;
    },
    domToMutation: function(xmlElement) {
        this.elseCount_ = parseInt(xmlElement.getAttribute('else'), 10);
        if (this.elseCount_) {
            this.appendStatementInput('SINON')
            .appendField('Sinon');
        }
    },
    decompose: function(workspace) {
        var containerBlock = Blockly.Block.obtain(workspace, 'si_alors_sinon_si');
        containerBlock.initSvg();
        var connection = containerBlock.getInput('STACK').connection;
        if (this.elseCount_) {
            var elseBlock = Blockly.Block.obtain(workspace, 'si_alors_sinon_sinon');
            elseBlock.initSvg();
            connection.connect(elseBlock.previousConnection);
        }
        return containerBlock;
    },
    compose: function(containerBlock) {
        if (this.elseCount_) {
            this.removeInput('SINON');
        }
        this.elseCount_ = 0;
        var clauseBlock = containerBlock.getInputTargetBlock('STACK');
        while (clauseBlock) {
            switch (clauseBlock.type) {
                case 'si_alors_sinon_sinon':
                    this.elseCount_++;
                    var elseInput = this.appendStatementInput('SINON');
                    elseInput.appendField('Sinon');
                    if (clauseBlock.statementConnection_) {
                        elseInput.connection.connect(clauseBlock.statementConnection_);
                    }
                    break;
                default:
                    throw 'Unknown block type.';
            }
        clauseBlock = clauseBlock.nextConnection &&
                      clauseBlock.nextConnection.targetBlock();
        }
    },
    saveConnections: function(containerBlock) {
        var clauseBlock = containerBlock.getInputTargetBlock('STACK');
        var i = 1;
        while (clauseBlock) {
            switch (clauseBlock.type) {
                case 'si_alors_sinon_si':
                    var inputDo = this.getInput('SINON');
                    clauseBlock.statementConnection_ =
                        inputDo && inputDo.connection.targetConnection;
                    break;
                default:
                    throw 'Unknown block type.';
            }
            clauseBlock = clauseBlock.nextConnection &&
            clauseBlock.nextConnection.targetBlock();
        }
    }
};

// Conteneur pour le mutator de Si (Si… Alors…)
Blockly.Blocks['si_alors_sinon_si'] = {
  init: function() {
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Si…');
    this.appendDummyInput()
        .appendField('Alors…');
    this.appendStatementInput('STACK');
    this.setTooltip('Peut accueillir un bloc Sinon');
    this.contextMenu = false;
  }
};
// Conteneur pour le mutator de Si (Sinon)
Blockly.Blocks['si_alors_sinon_sinon'] = {
  init: function() {
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Sinon');
    this.setPreviousStatement(true);
    this.setTooltip('Glisser pour ajouter un bloc Sinon');
    this.contextMenu = false;
  }
};

// Gen Si
// https://github.com/google/blockly/blob/master/generators/python/logic.js#L32
Blockly.MicroAlg['si'] = function(block) {
    var cond = Blockly.MicroAlg.statementToCode(block, 'COND') || '';
    var branch = Blockly.MicroAlg.statementToCode(block, 'ALORS') || '';
    branch = branch.replace(/\)\(/gm, ')\n' + Blockly.MicroAlg.INDENT + '(');
    var code = '(Si ' + cond.substring(Blockly.MicroAlg.INDENT.length) +
               '\n Alors\n' + branch;
    if (block.elseCount_) {
        branch = Blockly.MicroAlg.statementToCode(block, 'SINON') || '';
        branch = branch.replace(/\)\(/gm, ')\n' + Blockly.MicroAlg.INDENT + '(');
        code += '\n Sinon\n' + branch;
    }
    code += '\n)'
    return code;
};

// Bloc Tant_que
Blockly.Blocks['tant_que'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Tant_que');
    this.setColour(colour);
    this.appendValueInput('COND')
        .setCheck('Boolean')
        .appendField('Tant_que');
    this.appendStatementInput('INSTR')
        .appendField('Faire');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Structure itérative');
    },
};

// Gen Tant_que
Blockly.MicroAlg['tant_que'] = function(block) {
    var instr = Blockly.MicroAlg.statementToCode(block, 'INSTR') || '';
    var cond = Blockly.MicroAlg.statementToCode(block, 'COND') || '';
    instr = instr.replace(/\)\(/gm, ')\n' + Blockly.MicroAlg.INDENT + '(');
    var code = '(Tant_que ' + cond.trim() +
               '\nFaire\n' + instr;
    code += '\n)'
    return code;
};

// Bloc Tete
Blockly.Blocks['tete'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Tete');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Tete');
    this.setOutput(true);
    this.setTooltip('Retourne le premier élément d’un texte ou d’une liste.');
  }
};

// Gen Tete
Blockly.MicroAlg['tete'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Tete)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Tete ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Tete\n' + arg + '\n)';
  }
};

// Bloc Texte
Blockly.Blocks['texte'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Texte');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Texte');
    this.setOutput(true, 'String');
    this.setTooltip('Convertir une valeur en texte.');
  }
};

// Gen Texte
Blockly.MicroAlg['texte'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Texte)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Texte ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Texte\n' + arg + '\n)';
  }
};

// Bloc Type
Blockly.Blocks['type'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Type');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Type');
    this.setOutput(true, 'String');
    this.setTooltip('Convertir une valeur en texte.');
  }
};

// Gen Type
Blockly.MicroAlg['type'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Type)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Type ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Type\n' + arg + '\n)';
  }
};

// Bloc Vide?
Blockly.Blocks['vide?'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Vide?');
    this.setColour(colour);
    this.appendValueInput('VALUE')
        .appendField('Vide?');
    this.setOutput(true, 'Boolean');
    this.setTooltip('Teste si un texte ou une liste est vide.');
  }
};

// Gen Vide?
Blockly.MicroAlg['vide?'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  if (arg === '') return '(Vide?)';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(Vide? ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(Vide?\n' + arg + '\n)';
  }
};

// Bloc texte littéral
Blockly.Blocks['texte_litteral'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#textesavecblockly');
    this.setColour(colour);
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

// Gen texte littéral
Blockly.MicroAlg['texte_litteral'] = function(block) {
  var code = Blockly.MicroAlg.quote_(block.getFieldValue('TEXT'));
  return code;
};

// Bloc nombre littéral
Blockly.Blocks['nombre_litteral'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#nombresavecblockly');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField(new Blockly.FieldTextInput('0',
        Blockly.FieldTextInput.numberValidator), 'NUM');
    this.setOutput(true, 'Number');
    this.setTooltip("Nombre");
  }
};

// Gen nombre littéral
Blockly.MicroAlg['nombre_litteral'] = function(block) {
  return block.getFieldValue('NUM');
};

// Bloc opérations
Blockly.Blocks['operations'] = {
  init: function() {
    var OPERATORS =
        [['Somme',      'ADD'],
         ['Différence', 'MINUS'],
         ['Produit',    'MULTIPLY'],
         ['Quotient',   'DIVIDE'],
         ['Reste',      'MOD'],
         ['Puissance ', 'POW']];
    this.setHelpUrl(malg_url + '#oprationsavecblockly');
    this.setColour(colour);
    this.setOutput(true, 'Number');
    this.appendValueInput('A')
        .appendField(new Blockly.FieldDropdown(OPERATORS), 'OP')
        .setCheck('Number');
    this.appendValueInput('B')
        .setCheck('Number');
    // Assign 'this' to a variable for use in the tooltip closure below.
    var thisBlock = this;
    this.setTooltip(function() {
      var mode = thisBlock.getFieldValue('OP');
      var TOOLTIPS = {
        'ADD'     : "Retourne la somme des deux nombres.",
        'MINUS'   : "Retourne le quotient des deux nombres.",
        'MULTIPLY': "Retourne la différence des deux nombres.",
        'DIVIDE'  : "Retourne le produit des deux nombres.",
        'MOD'     : "Retourne le reste de la div. euclidienne des deux nombres.",
        'POW'     : "Retourne le premier nombre à la puissance du deuxième.",
      };
      return TOOLTIPS[mode];
    });
  }
};

// Gen opérations
Blockly.MicroAlg['operations'] = function(block) {
  var OPERATORS = {
    'ADD':      '+',
    'MINUS':    '-',
    'MULTIPLY': '*',
    'DIVIDE':   '/',
    'MOD':      '%',
    'POW':      '^',
  };
  var operator = OPERATORS[block.getFieldValue('OP')];
  var inputA = Blockly.MicroAlg.statementToCode(block, 'A');
  var inputB = Blockly.MicroAlg.statementToCode(block, 'B');
  var argument0 = inputA.substring(Blockly.MicroAlg.INDENT.length) || '0';
  var argument1 = inputB.substring(Blockly.MicroAlg.INDENT.length) || '0';
  var code = '(' + operator + ' ' + argument0 + ' ' + argument1 + ')';
  return code;
};

// Bloc comparaisons
Blockly.Blocks['comparaisons'] = {
  init: function() {
    var OPERATORS =
        [['=', 'EQ'],
         ['≠', 'NEQ'],
         ['<', 'INF'],
         ['>', 'SUP'],
         ['≤', 'INFEQ'],
         ['≥', 'SUPEQ']];
    this.setHelpUrl(malg_url + '#comparaisonsavecblockly');
    this.setColour(colour);
    this.setOutput(true, 'Boolean');
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown(OPERATORS), 'COMP');
    this.appendValueInput('A');
    this.appendValueInput('B');
    this.setInputsInline(true);
    // Assign 'this' to a variable for use in the tooltip closure below.
    var thisBlock = this;
    this.setTooltip(function() {
      var mode = thisBlock.getFieldValue('COMP');
      var TOOLTIPS = {
        '=': "Retourne Vrai si les arguments sont égaux.",
        '≠': "Retourne Vrai si les arguments sont différents.",
        '<': "Retourne Vrai si le premier argument est strictement inférieur au second.",
        '>': "Retourne Vrai si le premier argument est strictement supérieur au second.",
        '≤': "Retourne Vrai si le premier argument est inférieur ou égal au second.",
        '≥': "Retourne Vrai si le premier argument est supérieur ou égal au second."
      };
      return TOOLTIPS[mode];
    });
  }
};

// Gen comparaisons
Blockly.MicroAlg['comparaisons'] = function(block) {
  var OPERATORS = {
    'EQ':    '=',
    'NEQ':   '=/',
    'INF':   '<',
    'SUP':   '>',
    'INFEQ': '<=',
    'SUPEQ': '>='
  };
  var operator = OPERATORS[block.getFieldValue('COMP')];
  var inputA = Blockly.MicroAlg.statementToCode(block, 'A');
  var inputB = Blockly.MicroAlg.statementToCode(block, 'B');
  var argument0 = inputA.substring(Blockly.MicroAlg.INDENT.length) || '';
  var argument1 = inputB.substring(Blockly.MicroAlg.INDENT.length) || '';
  var code = '(' + operator + ' ' + argument0 + ' ' + argument1 + ')';
  return code;
};

// Bloc Faux
Blockly.Blocks['faux'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Faux');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Faux');
    this.setOutput(true);
    this.setTooltip('Booléen valant Faux.');
  }
};

// Gen Faux
Blockly.MicroAlg['faux'] = function(block) {
  return 'Faux';
};

// Bloc Vrai
Blockly.Blocks['vrai'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Vrai');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Vrai');
    this.setOutput(true);
    this.setTooltip('Booléen valant Vrai.');
  }
};

// Gen Vrai
Blockly.MicroAlg['vrai'] = function(block) {
  return 'Vrai';
};

// Bloc Rien
Blockly.Blocks['rien'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Rien');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Rien');
    this.setOutput(true);
    this.setTooltip('Valeur n’ayant pas vraiment de valeur.');
  }
};

// Gen Rien
Blockly.MicroAlg['rien'] = function(block) {
  return 'Rien';
};

// Bloc RAZ
Blockly.Blocks['raz'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-RAZ');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('RAZ');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Remise À Zéro de la fenêtre graphique.');
  }
};

// Gen RAZ
Blockly.MicroAlg['raz'] = function(block) {
  return '(RAZ)';
};

// Bloc Cercle
Blockly.Blocks['cercle'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Cercle');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Cercle');
    this.appendValueInput("ORIG_X")
        .setCheck('Number')
        .appendField('X');
    this.appendValueInput("ORIG_Y")
        .setCheck('Number')
        .appendField('Y');
    this.appendValueInput("R")
        .setCheck('Number')
        .appendField('R');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Dessine le cercle de centre (X,Y) et de rayon R.');
  }
};

// Gen Cercle
Blockly.MicroAlg['cercle'] = function(block) {
  var x = Blockly.MicroAlg.statementToCode(block, 'ORIG_X') || '';
  var y = Blockly.MicroAlg.statementToCode(block, 'ORIG_Y') || '';
  var r = Blockly.MicroAlg.statementToCode(block, 'R') || '';
  return '(Cercle (Liste ' + x.trim() + ' ' + y.trim() + ') ' + r.trim() + ')';
};

// Bloc Contour
Blockly.Blocks['contour'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Contour');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Contour');
    this.appendValueInput("R")
        .setCheck('Number')
        .appendField('R');
    this.appendValueInput("V")
        .setCheck('Number')
        .appendField('V');
    this.appendValueInput("B")
        .setCheck('Number')
        .appendField('B');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Change la couleur des contours.');
  }
};

// Gen Contour
Blockly.MicroAlg['contour'] = function(block) {
  var r = Blockly.MicroAlg.statementToCode(block, 'R') || '';
  var v = Blockly.MicroAlg.statementToCode(block, 'V') || '';
  var b = Blockly.MicroAlg.statementToCode(block, 'B') || '';
  return '(Contour (Liste ' + r.trim() + ' ' + v.trim() + ' ' + b.trim() + '))';
};

// Bloc Contour avec canal alpha
Blockly.Blocks['contour-alpha'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Contour');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Contour');
    this.appendValueInput("R")
        .setCheck('Number')
        .appendField('R');
    this.appendValueInput("V")
        .setCheck('Number')
        .appendField('V');
    this.appendValueInput("B")
        .setCheck('Number')
        .appendField('B');
    this.appendValueInput("A")
        .setCheck('Number')
        .appendField('A');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Change la couleur des contours.');
  }
};

// Gen Contour avec canal alpha
Blockly.MicroAlg['contour-alpha'] = function(block) {
  var r = Blockly.MicroAlg.statementToCode(block, 'R') || '';
  var v = Blockly.MicroAlg.statementToCode(block, 'V') || '';
  var b = Blockly.MicroAlg.statementToCode(block, 'B') || '';
  var a = Blockly.MicroAlg.statementToCode(block, 'A') || '';
  return '(Contour (Liste ' + r.trim() + ' ' + v.trim() + ' ' + b.trim() + ' ' + a.trim() + '))';
};

// Bloc Ellipse
Blockly.Blocks['ellipse'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Ellipse');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Ellipse');
    this.appendValueInput("ORIG_X")
        .setCheck('Number')
        .appendField('X');
    this.appendValueInput("ORIG_Y")
        .setCheck('Number')
        .appendField('Y');
    this.appendValueInput("R1")
        .setCheck('Number')
        .appendField('R1');
    this.appendValueInput("R2")
        .setCheck('Number')
        .appendField('R2');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Dessine l’ellipse de centre (X,Y) et de rayons R1 et R2.');
  }
};

// Gen Ellipse
Blockly.MicroAlg['ellipse'] = function(block) {
  var x = Blockly.MicroAlg.statementToCode(block, 'ORIG_X') || '';
  var y = Blockly.MicroAlg.statementToCode(block, 'ORIG_Y') || '';
  var r1 = Blockly.MicroAlg.statementToCode(block, 'R1') || '';
  var r2 = Blockly.MicroAlg.statementToCode(block, 'R2') || '';
  return '(Ellipse (Liste ' + x.trim() + ' ' + y.trim() + ') ' +
                              r1.trim() + ' ' + r2.trim() + ')';
};

// Bloc Epaisseur
Blockly.Blocks['epaisseur'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Epaisseur');
    this.setColour(colour);
    this.appendValueInput("E")
        .setCheck('Number')
        .appendField('Epaisseur');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Définit l’épaisseur des contours.');
  }
};

// Gen Epaisseur
Blockly.MicroAlg['epaisseur'] = function(block) {
  var e = Blockly.MicroAlg.statementToCode(block, 'E') || '';
  return '(Epaisseur ' + e.trim() + ')';
};

// Bloc Rectangle
Blockly.Blocks['rectangle'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Rectangle');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Rectangle');
    this.appendValueInput("X1")
        .setCheck('Number')
        .appendField('X1');
    this.appendValueInput("Y1")
        .setCheck('Number')
        .appendField('Y1');
    this.appendValueInput("X2")
        .setCheck('Number')
        .appendField('X2');
    this.appendValueInput("Y2")
        .setCheck('Number')
        .appendField('Y2');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Dessine le rectangle de sommets opposés (X1,Y1) et (X2,Y2).');
  }
};

// Gen Rectangle
Blockly.MicroAlg['rectangle'] = function(block) {
  var x1 = Blockly.MicroAlg.statementToCode(block, 'X1') || '';
  var y1 = Blockly.MicroAlg.statementToCode(block, 'Y1') || '';
  var x2 = Blockly.MicroAlg.statementToCode(block, 'X2') || '';
  var y2 = Blockly.MicroAlg.statementToCode(block, 'Y2') || '';
  return '(Rectangle (Liste ' + x1.trim() + ' ' + y1.trim() + ') ' +
                    '(Liste ' + x2.trim() + ' ' + y2.trim() + '))';
};

// Bloc Remplissage
Blockly.Blocks['remplissage'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Remplissage');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Remplissage');
    this.appendValueInput("R")
        .setCheck('Number')
        .appendField('R');
    this.appendValueInput("V")
        .setCheck('Number')
        .appendField('V');
    this.appendValueInput("B")
        .setCheck('Number')
        .appendField('B');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Change la couleur du remplissage des formes.');
  }
};

// Gen Remplissage
Blockly.MicroAlg['remplissage'] = function(block) {
  var r = Blockly.MicroAlg.statementToCode(block, 'R') || '';
  var v = Blockly.MicroAlg.statementToCode(block, 'V') || '';
  var b = Blockly.MicroAlg.statementToCode(block, 'B') || '';
  return '(Remplissage (Liste ' + r.trim() + ' ' + v.trim() + ' ' + b.trim() + '))';
};

// Bloc Remplissage avec canal alpha
Blockly.Blocks['remplissage-alpha'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Remplissage');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Remplissage');
    this.appendValueInput("R")
        .setCheck('Number')
        .appendField('R');
    this.appendValueInput("V")
        .setCheck('Number')
        .appendField('V');
    this.appendValueInput("B")
        .setCheck('Number')
        .appendField('B');
    this.appendValueInput("A")
        .setCheck('Number')
        .appendField('A');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Change la couleur du remplissage des formes.');
  }
};

// Gen Remplissage avec canal alpha
Blockly.MicroAlg['remplissage-alpha'] = function(block) {
  var r = Blockly.MicroAlg.statementToCode(block, 'R') || '';
  var v = Blockly.MicroAlg.statementToCode(block, 'V') || '';
  var b = Blockly.MicroAlg.statementToCode(block, 'B') || '';
  var a = Blockly.MicroAlg.statementToCode(block, 'A') || '';
  return '(Remplissage (Liste ' + r.trim() + ' ' + v.trim() + ' ' + b.trim() + ' ' + a.trim() + '))';
};

// Bloc Segment
Blockly.Blocks['segment'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Segment');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Segment');
    this.appendValueInput("X1")
        .setCheck('Number')
        .appendField('X1');
    this.appendValueInput("Y1")
        .setCheck('Number')
        .appendField('Y1');
    this.appendValueInput("X2")
        .setCheck('Number')
        .appendField('X2');
    this.appendValueInput("Y2")
        .setCheck('Number')
        .appendField('Y2');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Dessine le segment d’extrémités (X1,Y1) et (X2,Y2).');
  }
};

// Gen Segment
Blockly.MicroAlg['segment'] = function(block) {
  var x1 = Blockly.MicroAlg.statementToCode(block, 'X1') || '';
  var y1 = Blockly.MicroAlg.statementToCode(block, 'Y1') || '';
  var x2 = Blockly.MicroAlg.statementToCode(block, 'X2') || '';
  var y2 = Blockly.MicroAlg.statementToCode(block, 'Y2') || '';
  return '(Segment (Liste ' + x1.trim() + ' ' + y1.trim() + ') ' +
                  '(Liste ' + x2.trim() + ' ' + y2.trim() + '))';
};

// Bloc Triangle
Blockly.Blocks['triangle'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-Triangle');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('Triangle');
    this.appendValueInput("X1")
        .setCheck('Number')
        .appendField('X1');
    this.appendValueInput("Y1")
        .setCheck('Number')
        .appendField('Y1');
    this.appendValueInput("X2")
        .setCheck('Number')
        .appendField('X2');
    this.appendValueInput("Y2")
        .setCheck('Number')
        .appendField('Y2');
    this.appendValueInput("X3")
        .setCheck('Number')
        .appendField('X3');
    this.appendValueInput("Y3")
        .setCheck('Number')
        .appendField('Y3');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Dessine le triangle de sommets (X1,Y1), (X2,Y2) et (X3,Y3).');
  }
};

// Gen Triangle
Blockly.MicroAlg['triangle'] = function(block) {
  var x1 = Blockly.MicroAlg.statementToCode(block, 'X1') || '';
  var y1 = Blockly.MicroAlg.statementToCode(block, 'Y1') || '';
  var x2 = Blockly.MicroAlg.statementToCode(block, 'X2') || '';
  var y2 = Blockly.MicroAlg.statementToCode(block, 'Y2') || '';
  var x3 = Blockly.MicroAlg.statementToCode(block, 'X3') || '';
  var y3 = Blockly.MicroAlg.statementToCode(block, 'Y3') || '';
  return '(Triangle (Liste ' + x1.trim() + ' ' + y1.trim() + ') ' +
                   '(Liste ' + x2.trim() + ' ' + y2.trim() + ') ' +
                   '(Liste ' + x3.trim() + ' ' + y3.trim() + '))';
};

// Bloc AV
Blockly.Blocks['av'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-AV');
    this.setColour(colour);
    this.appendValueInput("VALUE")
        .setCheck('Number')
        .appendField('AV');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Avance la tortue d’un certain nombre de pixels.');
  }
};

// Gen AV
Blockly.MicroAlg['av'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(AV ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(AV\n' + arg + '\n)';
  }
};

// Bloc BC
Blockly.Blocks['bc'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-BC');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('BC');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Baisse le crayon de la tortue.');
  }
};

// Gen BC
Blockly.MicroAlg['bc'] = function(block) {
  return '(BC)';
};

// Bloc LC
Blockly.Blocks['lc'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-LC');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('LC');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Lève le crayon de la tortue.');
  }
};

// Gen LC
Blockly.MicroAlg['lc'] = function(block) {
  return '(LC)';
};

// Bloc TD
Blockly.Blocks['td'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-TD');
    this.setColour(colour);
    this.appendValueInput("VALUE")
        .setCheck('Number')
        .appendField('TD');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Tourne la tortue vers la droite (en degrés).');
  }
};

// Gen TD
Blockly.MicroAlg['td'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(TD ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(TD\n' + arg + '\n)';
  }
};

// Bloc TD 90
Blockly.Blocks['td90'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-TD');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('TD');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Tourne la tortue vers la gauche (en degrés).');
  }
};

// Gen TD 90
Blockly.MicroAlg['td90'] = function(block) {
  return '(TD)';
};

// Bloc TG
Blockly.Blocks['tg'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-TG');
    this.setColour(colour);
    this.appendValueInput("VALUE")
        .setCheck('Number')
        .appendField('TG');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Tourne la tortue vers la gauche (en degrés).');
  }
};

// Gen TG
Blockly.MicroAlg['tg'] = function(block) {
  var arg = Blockly.MicroAlg.statementToCode(block, 'VALUE') || '';
  var num_lines = arg.split('\n').length;
  if (num_lines == 1) {
    // Prevent indentation if we only have one line.
    return '(TG ' + arg.substring(Blockly.MicroAlg.INDENT.length) + ')';
  } else {
    return '(TG\n' + arg + '\n)';
  }
};

// Bloc TG 90
Blockly.Blocks['tg90'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-TG');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('TG');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Tourne la tortue vers la gauche (en degrés).');
  }
};

// Gen TG 90
Blockly.MicroAlg['tg90'] = function(block) {
  return '(TG)';
};

// Bloc valeur_utilisateur
Blockly.Blocks['valeur_utilisateur'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-valeur_utilisateur');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('valeur_utilisateur');
    this.setOutput(true);
    this.setTooltip('Dernière valeur entrée par l’utilisateur.');
  }
};

// Gen valeur_utilisateur
Blockly.MicroAlg['valeur_utilisateur'] = function(block) {
  return 'valeur_utilisateur';
};

// Bloc credit_iterations
Blockly.Blocks['credit_iterations'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-credit_iterations');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('credit_iterations');
    this.setOutput(true);
    this.setTooltip('Nombre de tours restants pour Tant_que et Faire.');
  }
};

// Gen credit_iterations
Blockly.MicroAlg['credit_iterations'] = function(block) {
  return 'credit_iterations';
};

// Bloc sequence_tirages
Blockly.Blocks['sequence_tirages'] = {
  init: function() {
    this.setHelpUrl(malg_url + '#sym-sequence_tirages');
    this.setColour(colour);
    this.appendDummyInput()
        .appendField('sequence_tirages@');
    this.setOutput(true);
    this.setTooltip('Liste des entiers utilisés par Entier@ et Nieme@.');
  }
};

// Gen sequence_tirages
Blockly.MicroAlg['sequence_tirages'] = function(block) {
  return 'sequence_tirages@';
};