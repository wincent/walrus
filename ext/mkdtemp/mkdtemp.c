/* 
Copyright 2007 Wincent Colaiuta
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
#include <errno.h>
#include <unistd.h>

/*

call-seq:
    Dir.mkdtemp([string])   -> String or nil

This method securely creates temporary directories. It is a wrapper for the mkdtemp() function in the standard C library. It takes an optional String parameter as a template describing the desired form of the directory name; if no template is supplied then "/tmp/temp.XXXXXX" is used as a default.

*/
static VALUE walrus_dir_mkdtemp_m(int argc, VALUE *argv, VALUE self)
{
    VALUE template;
    if (rb_scan_args(argc, argv, "01", &template) == 0)                         /* check for 0 mandatory arguments, 1 optional argument */
        template = Qnil;                                                        /* default to nil if no argument passed */
    if (NIL_P(template))
        template = rb_str_new2("/tmp/temp.XXXXXX");                             /* fallback to this template if passed nil */
    SafeStringValue(template);                                                  /* raises if template is tainted and SAFE level > 0 */
    VALUE safe  = StringValue(template);                                        /* duck typing support */
    char *path  = mkdtemp(RSTRING(safe)->ptr);
    if (path == NULL)
        rb_raise(rb_eSystemCallError, "mkdtemp failed (error: %d)", errno);
    return rb_str_new2(path);
}

void Init_mkdtemp()
{
    rb_define_module_function(rb_cDir, "mkdtemp", walrus_dir_mkdtemp_m, -1);
}

