## Labels

Labels are ordinary strings which can end with a colon. Labels starting with `_` are considered to be local labels and do not show outside sections where they were defined, or outside object files, if they were not defined inside a section.

Here are few examples of different labels:

```
VBI_IRQ:
VBI_IRQ2
_VBI_LOOP:
main:
```

Labels starting with `@` are considered to be child labels. They can only be referenced within the scope of their parent labels, unless the full name is specified. When there is more than one @, the label is considered to be a child of a child.

Here are some examples of child labels:

```
PARENT1:
@CHILD:
@@SUBCHILD

PARENT2:
@CHILD:
```
This is legal, since each of the @CHILD labels has a different parent. You can specify a parent to be explicit, like so:

`jr PARENT1@CHILD@SUBCHILD`

## Number types

WLA support a few common ways to specify numbers.

| Example | Describtion |
| --- | --- |
| 1000 | decimal |
| $100 | hexadecimal |
| 100h | hexadecimal |
| %100 | binary |
| 'x' | character |

