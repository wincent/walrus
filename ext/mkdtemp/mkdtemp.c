/* 
Copyright 2007 Wincent Colaiuta
$Id$
*/

#include <ruby.h>
#include <errno.h>

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

