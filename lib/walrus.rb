# Copyright 2007 Wincent Colaiuta
# $Id$

require 'jcode'   # jlength method
$KCODE  = 'U'     # UTF-8 (necessary for Unicode support)

module Walrus
  
  VERSION = '0.1'
  
  autoload(:CompileError,                 'walrus/compile_error')
  autoload(:Compiler,                     'walrus/compiler')
  autoload(:Grammar,                      'walrus/grammar')
  autoload(:Parser,                       'walrus/parser')
  autoload(:NoParameterMarker,            'walrus/no_parameter_marker')
  autoload(:Template,                     'walrus/template')
  
  class Grammar
    
    autoload(:AndPredicate,                 'walrus/grammar/and_predicate')
    autoload(:ArrayResult,                  'walrus/grammar/array_result')
    autoload(:ContinuationWrapperException, 'walrus/grammar/continuation_wrapper_exception')
    autoload(:LocationTracking,             'walrus/grammar/location_tracking')
    autoload(:MatchDataWrapper,             'walrus/grammar/match_data_wrapper')
    autoload(:Memoizing,                    'walrus/grammar/memoizing')
    autoload(:MemoizingCache,               'walrus/grammar/memoizing_cache')
    autoload(:NotPredicate,                 'walrus/grammar/not_predicate')
    autoload(:Node,                         'walrus/grammar/node')
    autoload(:ParseError,                   'walrus/grammar/parse_error')
    autoload(:ParserState,                  'walrus/grammar/parser_state')
    autoload(:Parslet,                      'walrus/grammar/parslet')
    autoload(:ParsletChoice,                'walrus/grammar/parslet_choice')
    autoload(:ParsletCombination,           'walrus/grammar/parslet_combination')
    autoload(:ParsletCombining,             'walrus/grammar/parslet_combining')
    autoload(:ParsletMerge,                 'walrus/grammar/parslet_merge')
    autoload(:ParsletOmission,              'walrus/grammar/parslet_omission')
    autoload(:ParsletRepetition,            'walrus/grammar/parslet_repetition')
    autoload(:ParsletRepetitionDefault,     'walrus/grammar/parslet_repetition_default')
    autoload(:ParsletSequence,              'walrus/grammar/parslet_sequence')
    autoload(:Predicate,                    'walrus/grammar/predicate')
    autoload(:ProcParslet,                  'walrus/grammar/proc_parslet')
    autoload(:RegexpParslet,                'walrus/grammar/regexp_parslet')
    autoload(:SkippedSubstringException,    'walrus/grammar/skipped_substring_exception')
    autoload(:StringEnumerator,             'walrus/grammar/string_enumerator')
    autoload(:StringParslet,                'walrus/grammar/string_parslet')
    autoload(:StringResult,                 'walrus/grammar/string_result')
    autoload(:SymbolParslet,                'walrus/grammar/symbol_parslet')
    
  end
  
end # module Walrus

require 'walrus/additions/module'
require 'walrus/additions/string'
require 'walrus/grammar/additions/proc'
require 'walrus/grammar/additions/regexp'
require 'walrus/grammar/additions/string'
require 'walrus/grammar/additions/symbol'
