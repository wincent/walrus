/*
Copyright 2007-2010 Wincent Colaiuta
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <ruby.h>

/*

Common code used by almost identical "jindex" and "jrindex" methods. A C
extension is necessary here because with direct access to the rb_backref_get
and rb_backref_set API there is no way to propagate $~ back to the caller after
invoking the "index" and "rindex" methods. The code is basically equivalent to
the following Ruby code:

def index arg1, optional_arg
  index = super                                     # plus code here for deciding whether or not to pass optional argument
  match = ($~ ? $~.clone : nil)
  index unpack('C*')[0...index].pack('C*').jlength  # jlength clobbers $~ as a side effect, should consider rewriting it
  $~ = match                                        # in pure Ruby setting $~ here has only a local effect (not seen by caller)
  index
end

*/
static VALUE walrus_str_index_common(ID func, int argc, VALUE *argv, VALUE str)
{
    VALUE jindex                = Qnil;                                                                 /* default return value */
    VALUE index                 = rb_funcall2(str, func, argc, argv);                                   /* call String#index or String#rindex*/
    VALUE match                 = rb_backref_get();                                                     /* save $~ */
    if (!NIL_P(index))
    {
        VALUE packing_format    = rb_str_new2("C*");
        VALUE unpacked          = rb_funcall(str, rb_intern("unpack"), 1, packing_format);              /* unpack('C*') */
        VALUE range             = rb_funcall(rb_cRange, rb_intern("new"), 3, INT2FIX(0), index, Qtrue);
        VALUE slice             = rb_funcall(unpacked, rb_intern("slice"), 1, range);                   /* [0...idx] */
        VALUE packed            = rb_funcall(slice, rb_intern("pack"), 1, packing_format);              /* pack('C*') */
        jindex                  = rb_funcall(packed, rb_intern("jlength"), 0);                          /* jlength */
    }
    rb_backref_set(match);                                                                              /* restore $~ */
    return jindex;
}

/*

call-seq:
    str.jindex(substring [, offset])    -> Fixnum or nil
    str.jindex(fixnum [, offset])       -> Fixnum or nil
    str.jindex(regexp [, offset])       -> Fixnum or nil

Multibyte-friendly equivalent of the String#index method. If $KCODE is
appropriately set will return an accurate index based on character count rather
than byte counts.

*/
static VALUE walrus_str_jindex_m(int argc, VALUE *argv, VALUE str)
{
    return walrus_str_index_common(rb_intern("index"), argc, argv, str);
}

/*

call-seq:
    str.jrindex(substring [, offset])   -> Fixnum or nil
    str.jrindex(fixnum [, offset])      -> Fixnum or nil
    str.jrindex(regexp [, offset])      -> Fixnum or nil

Multibyte-friendly equivalent of the String#rindex method. If $KCODE is
appropriately set will return an accurate index based on character count rather
than byte counts.

*/
static VALUE walrus_str_jrindex_m(int argc, VALUE *argv, VALUE str)
{
    return walrus_str_index_common(rb_intern("rindex"), argc, argv, str);
}

void Init_jindex()
{
    rb_define_method(rb_cString, "jindex", walrus_str_jindex_m, -1);
    rb_define_method(rb_cString, "jrindex", walrus_str_jrindex_m, -1);
}
