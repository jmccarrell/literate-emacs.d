# Table of Contents

1.  [Jeffs Frequently Used Bindings](#org204565e)
    1.  [Recent bindings to get used to](#orgcb44bb2)
    2.  [Global bindings](#org2aa9637)
    3.  [Projectile bindings](#orgb53f62c)
    4.  [Org mode bindings](#org6f6d705)
    5.  [Register, Bookmark & Mark bindings](#org318b628)
    6.  [Agenda view bindings](#orge010a73)
2.  [Dired](#org1bb40d1)
    1.  [Key bindings](#org894ccbe)
3.  [Narrow](#orgbee4453)
    1.  [Narrow Common Key Bindings](#orga9c8bde)
4.  [Rectangles](#org99a76b2)
    1.  [Rectangle Mark Mode](#orge5df060)
    2.  [Rectangle Registers](#org22d349f)
5.  [Org key bindings](#org1647916)
    1.  [References](#orgbc2b710)
    2.  [End Notes](#orge354b33)
    3.  [Visibility Cycling](#org6a5f612)
    4.  [Motion](#orge9d7f82)
    5.  [Structure Editing](#orgd7dc133)
    6.  [Capture / Refile / Archiving](#orgc995ffc)
    7.  [Filtering and Sparse Trees](#org5e6ec20)
    8.  [Tables](#orge414022)
        1.  [Table Creation](#org840296b)
        2.  [Commands Inside a Table](#org5677cb1)
        3.  [Re-aligning and Field Motion](#org79426c9)
        4.  [Row and Column Editing](#orgc84986f)
        5.  [Regions](#org9c5ff36)
        6.  [Miscellaneous](#orge347d76)
        7.  [Tables created with the table.el package](#org78c6f23)
        8.  [Spreadsheet](#orge524d56)
        9.  [Formula Editor](#org54bab72)
    9.  [Links](#org4c7629f)
    10. [Working with Code (Babel)](#org65d81bc)
    11. [Completion](#orgdd437d7)
    12. [Items and Checkboxes](#orgbf165bf)
    13. [Tags](#orgfbdb2e1)
    14. [Properties and Column View](#orgc2292aa)
    15. [Timestamps](#orgea8b888)
        1.  [Clocking Time](#org1215a20)
    16. [Agenda Views](#org77f7bbb)
6.  [Register key bindings](#orga5465bc)
7.  [Bookmark key bindings](#org38d7583)
8.  [Company bindings](#org79f096a)
    1.  [While completing](#org7f9aeca)
    2.  [When a completion is selected](#orgb37a4e3)
9.  [Clojure / CIDER key bindings](#org9a8ac98)
    1.  [Clojure key bindings](#org12c39be)
    2.  [CIDER key bindings](#org17fb2ba)
10. [Outline key bindings](#orgba10ae6)
    1.  [Outline Motion](#orgecef7f8)
    2.  [Outline Visibility](#org9cc018a)


<a id="org204565e"></a>

# Jeffs Frequently Used Bindings


<a id="orgcb44bb2"></a>

## Recent bindings to get used to

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-.</td>
<td class="org-left">avy character timer; jump to 3-char pattern</td>
</tr>


<tr>
<td class="org-left">C-c C-r</td>
<td class="org-left">crux rename file and buffer</td>
</tr>


<tr>
<td class="org-left">C-c & C-s</td>
<td class="org-left">choose a snippet to insert</td>
</tr>


<tr>
<td class="org-left">s-x</td>
<td class="org-left">create an auto-snippet</td>
</tr>


<tr>
<td class="org-left">s-y</td>
<td class="org-left">expand auto-snippet</td>
</tr>
</tbody>
</table>


<a id="org2aa9637"></a>

## Global bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-s</td>
<td class="org-left">schedule a task on a date</td>
</tr>


<tr>
<td class="org-left">C-c l</td>
<td class="org-left">store a link, like in a file; region becomes search text</td>
</tr>


<tr>
<td class="org-left">C-c C-l</td>
<td class="org-left">create or edit an org mode link</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-s</td>
<td class="org-left">archive a subtree</td>
</tr>
</tbody>
</table>


<a id="orgb53f62c"></a>

## Projectile bindings

bbatsov's [key bindings table](https://github.com/bbatsov/projectile/blob/master/doc/usage.md#interactive-commands)

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c p f</td>
<td class="org-left">list files in project</td>
</tr>


<tr>
<td class="org-left">C-c p s s</td>
<td class="org-left">grep project for string</td>
</tr>


<tr>
<td class="org-left">C-c p k</td>
<td class="org-left">kill project buffers</td>
</tr>
</tbody>
</table>


<a id="org6f6d705"></a>

## Org mode bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c %</td>
<td class="org-left">Push the current position onto the mark ring</td>
</tr>


<tr>
<td class="org-left">C-c C-v d</td>
<td class="org-left">demarcate a block (select region first)</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-s</td>
<td class="org-left">move subtree to archive file</td>
</tr>
</tbody>
</table>


<a id="org318b628"></a>

## Register, Bookmark & Mark bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key binding</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-x r l</td>
<td class="org-left">list available bookmarks</td>
</tr>


<tr>
<td class="org-left">C-x r m</td>
<td class="org-left">set a bookmark</td>
</tr>


<tr>
<td class="org-left">C-x r b</td>
<td class="org-left">jump to a bookmark</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">C-x r s</td>
<td class="org-left">store region in register</td>
</tr>


<tr>
<td class="org-left">C-x r i</td>
<td class="org-left">insert contents of register</td>
</tr>


<tr>
<td class="org-left">C-x r SPC</td>
<td class="org-left">store point in register</td>
</tr>


<tr>
<td class="org-left">C-x r j</td>
<td class="org-left">jump to register</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">C-SPC</td>
<td class="org-left">set the mark</td>
</tr>


<tr>
<td class="org-left">C-u C-SPC</td>
<td class="org-left">jump to mark; repeat to go back in mark ring</td>
</tr>
</tbody>
</table>


<a id="orge010a73"></a>

## Agenda view bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">t</td>
<td class="org-left">move a task through its states</td>
</tr>


<tr>
<td class="org-left">z</td>
<td class="org-left">add a note to a task</td>
</tr>


<tr>
<td class="org-left">a or $</td>
<td class="org-left">archive done tasks</td>
</tr>
</tbody>
</table>


<a id="org1bb40d1"></a>

# Dired


<a id="org894ccbe"></a>

## Key bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-0 w or 0 w</td>
<td class="org-left">dired copy full path to clipboard</td>
</tr>
</tbody>
</table>


<a id="orgbee4453"></a>

# Narrow


<a id="orga9c8bde"></a>

## Narrow Common Key Bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-x n n</td>
<td class="org-left">narrow down to between point and mark</td>
</tr>


<tr>
<td class="org-left">C-x n w</td>
<td class="org-left">widen to make entire buffer visible again</td>
</tr>


<tr>
<td class="org-left">C-x n p</td>
<td class="org-left">narrow to current page</td>
</tr>


<tr>
<td class="org-left">C-x n d</td>
<td class="org-left">narrow-to-defun</td>
</tr>
</tbody>
</table>


<a id="org99a76b2"></a>

# Rectangles

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-x r k</td>
<td class="org-left">kill the text of the region-rectangle, saving its contents as the last killed rectangle</td>
</tr>


<tr>
<td class="org-left">C-x r M-w</td>
<td class="org-left">Save the text of the region-rectangle as the last killed rectangle</td>
</tr>


<tr>
<td class="org-left">C-x r d</td>
<td class="org-left">Delete the text of the region-rectangle</td>
</tr>


<tr>
<td class="org-left">C-x r y</td>
<td class="org-left">Yank the last killed rectangle with its upper left corner at point</td>
</tr>


<tr>
<td class="org-left">C-x r o</td>
<td class="org-left">Insert blank space to fill the space of the region-rectangle.  Pushes the previous contents to the right.</td>
</tr>


<tr>
<td class="org-left">C-x r N</td>
<td class="org-left">Insert line numbers along the left edge of the region rectangle.  Pushes content right</td>
</tr>


<tr>
<td class="org-left">C-x r c</td>
<td class="org-left">Clear region-rectangle by replacing its contents with spaces.</td>
</tr>


<tr>
<td class="org-left">M-x delete-whitespace-rectangle</td>
<td class="org-left">Delete whitespace in each of the lines of the rectangle, starting from the left edge column of the rect</td>
</tr>


<tr>
<td class="org-left">C-x r t <span class="underline">string</span> RET</td>
<td class="org-left">Replace rectangle contents with <span class="underline">string</span> on each line</td>
</tr>


<tr>
<td class="org-left">M-x string-insert-rectangle RET <span class="underline">string</span> RET</td>
<td class="org-left">Insert <span class="underline">string</span> on each line of rectangle.</td>
</tr>


<tr>
<td class="org-left">C-x SPC</td>
<td class="org-left">Toggle Rectangle Mark mode.</td>
</tr>
</tbody>
</table>


<a id="orge5df060"></a>

## Rectangle Mark Mode

when active, the region-rectangle is highlighted and can be shrunk/grown.  the standard kill and yank commands operate on it.


<a id="org22d349f"></a>

## Rectangle Registers

-   fill this out from [Rectangle Registers](<https://www.gnu.org/software/emacs/manual/html_node/emacs/Rectangle-Registers.html#Rectangle-Registers>)


<a id="org1647916"></a>

# Org key bindings


<a id="orgbc2b710"></a>

## References

-   textual reference card [<http://orgmode.org/orgcard.txt>]
-   pdf reference card [<http://orgmode.org/orgcard.pdf>]


<a id="orge354b33"></a>

## End Notes

[1] Only a suggested keybinding for this command.  Choose your own under ACTIVATION.
[2] Keybinding is subject to org-support-shift-select and org-replace-disputed-keys


<a id="org6a5f612"></a>

## Visibility Cycling

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">TAB</td>
<td class="org-left">rotate current subtree between states</td>
</tr>


<tr>
<td class="org-left">S-TAB</td>
<td class="org-left">rotate the entire buffer between states</td>
</tr>


<tr>
<td class="org-left">C-u C-u TAB</td>
<td class="org-left">restore property-dependent startup visibility</td>
</tr>


<tr>
<td class="org-left">C-u C-u C-u TAB</td>
<td class="org-left">show the whole file, including drawers</td>
</tr>


<tr>
<td class="org-left">C-c C-r</td>
<td class="org-left">reveal context around point</td>
</tr>
</tbody>
</table>


<a id="orge9d7f82"></a>

## Motion

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-n/p</td>
<td class="org-left">next/previous heading</td>
</tr>


<tr>
<td class="org-left">C-c C-f/b</td>
<td class="org-left">next/previous heading, same level</td>
</tr>


<tr>
<td class="org-left">C-c C-u</td>
<td class="org-left">backward to a higher level heading</td>
</tr>


<tr>
<td class="org-left">C-c C-j</td>
<td class="org-left">jump to another place in document</td>
</tr>


<tr>
<td class="org-left">S-UP/DOWN</td>
<td class="org-left">previous/next plain list item [2]</td>
</tr>
</tbody>
</table>


<a id="orgd7dc133"></a>

## Structure Editing

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">M-RET</td>
<td class="org-left">insert new heading/item at current level</td>
</tr>


<tr>
<td class="org-left">C-RET</td>
<td class="org-left">insert new heading after subtree</td>
</tr>


<tr>
<td class="org-left">M-S-RET</td>
<td class="org-left">insert TODO entry/checkbox after subtree</td>
</tr>


<tr>
<td class="org-left">C-c -</td>
<td class="org-left">turn (head)line into item, cycle item type</td>
</tr>


<tr>
<td class="org-left">C-c \*</td>
<td class="org-left">turn item/line into headline</td>
</tr>


<tr>
<td class="org-left">M-LEFT/RIGHT</td>
<td class="org-left">promote/demote heading</td>
</tr>


<tr>
<td class="org-left">C-c C-</C-></td>
<td class="org-left">promote / demote sub tree</td>
</tr>


<tr>
<td class="org-left">M-S-UP/DOWN</td>
<td class="org-left">move subtree/list item up/down</td>
</tr>


<tr>
<td class="org-left">C-c ^</td>
<td class="org-left">sort subtree/region/plain-list</td>
</tr>


<tr>
<td class="org-left">C-c C-x c</td>
<td class="org-left">clone a subtree</td>
</tr>


<tr>
<td class="org-left">C-c C-x v</td>
<td class="org-left">copy visible text</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-w/M-w</td>
<td class="org-left">kill/copy subtree</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-y or C-y</td>
<td class="org-left">yank subtree</td>
</tr>


<tr>
<td class="org-left">C-x n s/w</td>
<td class="org-left">narrow buffer to subtree / widen</td>
</tr>
</tbody>
</table>


<a id="orgc995ffc"></a>

## Capture / Refile / Archiving

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c c</td>
<td class="org-left">capture a new item (C-u C-u == goto last) [1]</td>
</tr>


<tr>
<td class="org-left">C-c C-w</td>
<td class="org-left">refile subtree (C-u C-u == goto last)</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-a</td>
<td class="org-left">archive subtree using the default command</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-s</td>
<td class="org-left">move subtree to archive file</td>
</tr>


<tr>
<td class="org-left">C-c C-x a/A</td>
<td class="org-left">toggle ARCHIVE tag / to ARCHIVE sibling</td>
</tr>


<tr>
<td class="org-left">C-TAB</td>
<td class="org-left">force cycling of an ARCHIVEd tree</td>
</tr>
</tbody>
</table>


<a id="org5e6ec20"></a>

## Filtering and Sparse Trees

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c /</td>
<td class="org-left">construct a sparse tree by various criterial</td>
</tr>


<tr>
<td class="org-left">C-c / t/T</td>
<td class="org-left">view TODO's in a sparse tree</td>
</tr>


<tr>
<td class="org-left">C-c a t</td>
<td class="org-left">global TODO list in agenda mode [1]</td>
</tr>


<tr>
<td class="org-left">C-c a L</td>
<td class="org-left">time sorted view of current org file</td>
</tr>
</tbody>
</table>


<a id="orge414022"></a>

## Tables


<a id="org840296b"></a>

### Table Creation

just start typing, eg,   |key|good for| - TAB

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">key</td>
<td class="org-left">good for</td>
</tr>


<tr>
<td class="org-left">C-c &vert;</td>
<td class="org-left">convert region to table</td>
</tr>


<tr>
<td class="org-left">C-3 C-c &vert;</td>
<td class="org-left">convert region to table with separator of at least 3 spaces</td>
</tr>
</tbody>
</table>


<a id="org5677cb1"></a>

### Commands Inside a Table

the following commands work when the cursor is inside a table.
Outside of tables, these bindings may have other functionality.


<a id="org79426c9"></a>

### Re-aligning and Field Motion

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">command</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-c</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">realign the table without moving the cursor</td>
</tr>


<tr>
<td class="org-left">TAB</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">realign the table, move to the next field</td>
</tr>


<tr>
<td class="org-left">S-TAB</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">previous field</td>
</tr>


<tr>
<td class="org-left">RET</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">realign the table; move to next row</td>
</tr>


<tr>
<td class="org-left">M-a/e</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">move to beginning/end of field</td>
</tr>
</tbody>
</table>


<a id="orgc84986f"></a>

### Row and Column Editing

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">M-LEFT/RIGHT</td>
<td class="org-left">move the column left/right</td>
</tr>


<tr>
<td class="org-left">M-S-LEFT</td>
<td class="org-left">kill the current column</td>
</tr>


<tr>
<td class="org-left">M-S-RIGHT</td>
<td class="org-left">insert new column to the left of point</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">M-UP/DOWN</td>
<td class="org-left">move the current row up/down</td>
</tr>


<tr>
<td class="org-left">M-S-UP</td>
<td class="org-left">kill the current row or horizontal line</td>
</tr>


<tr>
<td class="org-left">M-S-DOWN</td>
<td class="org-left">insert new row above the current row</td>
</tr>


<tr>
<td class="org-left">C-c -</td>
<td class="org-left">insert horizontal line below (C-u : above) current row</td>
</tr>


<tr>
<td class="org-left">C-c RET</td>
<td class="org-left">insert horizontal line and move to the line below it</td>
</tr>


<tr>
<td class="org-left">C-c ^</td>
<td class="org-left">sort lines region</td>
</tr>
</tbody>
</table>


<a id="org9c5ff36"></a>

### Regions

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-x C-w/M-w/C-y</td>
<td class="org-left">cut/copy/paste rectangular region</td>
</tr>


<tr>
<td class="org-left">C-c C-q</td>
<td class="org-left">fill paragraph across selected cells</td>
</tr>
</tbody>
</table>


<a id="orge347d76"></a>

### Miscellaneous

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">&#x2026;&vert; <N> &vert;&#x2026;</td>
<td class="org-left">to limit column width to N characters wide</td>
</tr>


<tr>
<td class="org-left">C-c \`</td>
<td class="org-left">edit the current field in a separate window</td>
</tr>


<tr>
<td class="org-left">C-u TAB</td>
<td class="org-left">make the current field fully visible</td>
</tr>


<tr>
<td class="org-left">M-x org-table-export</td>
<td class="org-left">export as tab-separated file</td>
</tr>


<tr>
<td class="org-left">M-x org-table-import</td>
<td class="org-left">import tab-separated file</td>
</tr>


<tr>
<td class="org-left">C-c +</td>
<td class="org-left">sum numbers in current column/rectangle</td>
</tr>
</tbody>
</table>


<a id="org78c6f23"></a>

### Tables created with the table.el package

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c ~</td>
<td class="org-left">insert a new table.el table</td>
</tr>


<tr>
<td class="org-left">C-c C-c</td>
<td class="org-left">recognize existing table.el table</td>
</tr>


<tr>
<td class="org-left">C-c ~</td>
<td class="org-left">convert table (Org-mod <-> table.el)</td>
</tr>
</tbody>
</table>


<a id="orge524d56"></a>

### Spreadsheet

-   Formulas type in field are executed by TAB, RET and C-c C-c.
-   = introduces a column formula.
-   := a field formula

-   jwm: this looks quite powerful, but I'll have to go through the tutorial to make sense of it.
-   in particular, I don't quite understand how expressions are evaluated, and how to correct errors.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">good for</th>
<th scope="col" class="org-right">a</th>
<th scope="col" class="org-right">b</th>
<th scope="col" class="org-right">sum</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">#+TBLFM: =$3+$4</td>
<td class="org-left">Eg: add col3 and col4</td>
<td class="org-right">42</td>
<td class="org-right">33</td>
<td class="org-right">75</td>
</tr>


<tr>
<td class="org-left">#+TBLFM: $5=$3+$4;%.2f</td>
<td class="org-left">&#x2026; with printf format spec</td>
<td class="org-right">3.14159</td>
<td class="org-right">42</td>
<td class="org-right">45.14159</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#x2026; with constants from constants.el</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">:=vsum(@II.@III)</td>
<td class="org-left">sum from second to third horiz line</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">XXX</td>
<td class="org-left">jwm: more work needed here</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
</tr>
</tbody>
</table>


<a id="org54bab72"></a>

### Formula Editor

-   fill this out from formula editor section


<a id="org4c7629f"></a>

## Links

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c l</td>
<td class="org-left">globally store link to the current location [1]</td>
</tr>


<tr>
<td class="org-left">C-c C-l</td>
<td class="org-left">insert a link (TAB completes stored links)</td>
</tr>


<tr>
<td class="org-left">C-u C-c C-l</td>
<td class="org-left">insert a file link with file name completion</td>
</tr>


<tr>
<td class="org-left">C-c C-l</td>
<td class="org-left">edit (also hidden part of) link at point</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">C-c C-o/mouse-1/2</td>
<td class="org-left">open file links in emacs</td>
</tr>


<tr>
<td class="org-left">C-u C-c C-o/mouse-3</td>
<td class="org-left">&#x2026;force open in emacs/other window</td>
</tr>


<tr>
<td class="org-left">C-c %</td>
<td class="org-left">record a position in the mark ring</td>
</tr>


<tr>
<td class="org-left">C-c &</td>
<td class="org-left">jump back to last followed link(s)</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-n/C-p</td>
<td class="org-left">find next/previous link</td>
</tr>


<tr>
<td class="org-left">C-c '</td>
<td class="org-left">edit code snippet of file at point</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-v</td>
<td class="org-left">toggle inline display of linked images</td>
</tr>
</tbody>
</table>


<a id="org65d81bc"></a>

## Working with Code (Babel)

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-c</td>
<td class="org-left">execute code block at point</td>
</tr>


<tr>
<td class="org-left">C-c C-o</td>
<td class="org-left">open results of code block at point</td>
</tr>


<tr>
<td class="org-left">C-c C-v c</td>
<td class="org-left">check code block at point for errors.</td>
</tr>


<tr>
<td class="org-left">C-c C-v j</td>
<td class="org-left">insert a header argument with completion</td>
</tr>


<tr>
<td class="org-left">C-c C-v v</td>
<td class="org-left">view expanded body of code block at point</td>
</tr>


<tr>
<td class="org-left">C-c C-v I</td>
<td class="org-left">view info about code block at point</td>
</tr>


<tr>
<td class="org-left">C-c C-v g</td>
<td class="org-left">goto named code block</td>
</tr>


<tr>
<td class="org-left">C-c C-v r</td>
<td class="org-left">goto named result</td>
</tr>


<tr>
<td class="org-left">C-c C-v u</td>
<td class="org-left">goto head of the current code block</td>
</tr>


<tr>
<td class="org-left">C-c C-v n/p</td>
<td class="org-left">goto next/previous code block</td>
</tr>


<tr>
<td class="org-left">C-c C-v d</td>
<td class="org-left">demarcate a code block; how to insert the markers</td>
</tr>


<tr>
<td class="org-left">C-c C-v x</td>
<td class="org-left">execute the next key sequence in the code edit buffer</td>
</tr>


<tr>
<td class="org-left">C-c C-v b</td>
<td class="org-left">execute all the code blocks in current buffer</td>
</tr>


<tr>
<td class="org-left">C-c C-v s</td>
<td class="org-left">&#x2026; subtree</td>
</tr>


<tr>
<td class="org-left">C-c C-v t</td>
<td class="org-left">tangle code blocks in current file</td>
</tr>


<tr>
<td class="org-left">C-c C-v f</td>
<td class="org-left">&#x2026; supplied file</td>
</tr>


<tr>
<td class="org-left">C-c C-v i</td>
<td class="org-left">ingest all code blocks in supplied file into Library of Bable</td>
</tr>


<tr>
<td class="org-left">C-c C-v z</td>
<td class="org-left">switch to the session of the current code block</td>
</tr>


<tr>
<td class="org-left">C-c C-v l</td>
<td class="org-left">load the current code block into a session</td>
</tr>


<tr>
<td class="org-left">C-c C-v a</td>
<td class="org-left">view the SHA1 of the current code block</td>
</tr>
</tbody>
</table>


<a id="orgdd437d7"></a>

## Completion

-   In-buffer completion completes:
    -   TODO keywords at headline start
    -   TeX macros after backslash \\
    -   option keywords after #-
    -   TAGS after :
    -   dictionary words elsewhere

-   no doubt this is influenced by helm.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">M-TAB</td>
<td class="org-left">complete-word-at-point</td>
</tr>
</tbody>
</table>


<a id="orgbf165bf"></a>

## TODO Items and Checkboxes

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-t</td>
<td class="org-left">rotate the state of the current item</td>
</tr>


<tr>
<td class="org-left">S-LEFT/RIGHT</td>
<td class="org-left">select next/previous state</td>
</tr>


<tr>
<td class="org-left">C-S-LEFT/RIGHT</td>
<td class="org-left">select next/previous set</td>
</tr>


<tr>
<td class="org-left">C-c C-x o</td>
<td class="org-left">toggle ORDERED property</td>
</tr>


<tr>
<td class="org-left">C-c C-v</td>
<td class="org-left">view TODO items in a sparse tree</td>
</tr>


<tr>
<td class="org-left">C-3 C-v C-v</td>
<td class="org-left">view 3rd TODO keyword's sparse tree</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">C-c , [ABC]</td>
<td class="org-left">set the priority of the current item</td>
</tr>


<tr>
<td class="org-left">C-c , SPC</td>
<td class="org-left">remove priority cookie from current item</td>
</tr>


<tr>
<td class="org-left">S-UP/DOWN</td>
<td class="org-left">raise/lower priority of current item [1]</td>
</tr>


<tr>
<td class="org-left">M-S-RET</td>
<td class="org-left">insert new checkbox item in plain list</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-b</td>
<td class="org-left">toggle checkbox(es) in region/entry/at point</td>
</tr>


<tr>
<td class="org-left">C-c C-c</td>
<td class="org-left">toggle checkbox at point</td>
</tr>


<tr>
<td class="org-left">C-c #</td>
<td class="org-left">update checkbox statistics (C-u : whole file)</td>
</tr>
</tbody>
</table>


<a id="orgfbdb2e1"></a>

## Tags

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-q</td>
<td class="org-left">set tags for current heading</td>
</tr>


<tr>
<td class="org-left">C-u C-c C-q</td>
<td class="org-left">realign tags in all headings</td>
</tr>


<tr>
<td class="org-left">C-c \\\\</td>
<td class="org-left">create sparse tree with matching tags</td>
</tr>


<tr>
<td class="org-left">C-c C-o</td>
<td class="org-left">globally (agenda) match tags at cursor</td>
</tr>
</tbody>
</table>


<a id="orgc2292aa"></a>

## Properties and Column View

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-x p/e</td>
<td class="org-left">set property/effort</td>
</tr>


<tr>
<td class="org-left">C-c C-c</td>
<td class="org-left">special commands in property lines</td>
</tr>


<tr>
<td class="org-left">S-LEFT/RIGHT</td>
<td class="org-left">next/previous allowed value</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-c</td>
<td class="org-left">turn on column view</td>
</tr>


<tr>
<td class="org-left">C-c C-x i</td>
<td class="org-left">capture columns view in dynamic block</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">q</td>
<td class="org-left">quit column view</td>
</tr>


<tr>
<td class="org-left">v</td>
<td class="org-left">show full value</td>
</tr>


<tr>
<td class="org-left">e</td>
<td class="org-left">edit value</td>
</tr>


<tr>
<td class="org-left">n/p or S-LEFT/RIGHT</td>
<td class="org-left">next/previous allowed value</td>
</tr>


<tr>
<td class="org-left">a</td>
<td class="org-left">edit allowed values list</td>
</tr>


<tr>
<td class="org-left">>/<</td>
<td class="org-left">make column wider/narrower</td>
</tr>


<tr>
<td class="org-left">M-LEFT/RIGHT</td>
<td class="org-left">move column left/right</td>
</tr>


<tr>
<td class="org-left">M-S-RIGHT</td>
<td class="org-left">add new column</td>
</tr>


<tr>
<td class="org-left">M-S-LEFT</td>
<td class="org-left">delete current column</td>
</tr>
</tbody>
</table>


<a id="orgea8b888"></a>

## Timestamps

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c .</td>
<td class="org-left">prompt for date and insert timestamp</td>
</tr>


<tr>
<td class="org-left">C-u C-c .</td>
<td class="org-left">&#x2026; but prompt for date/time format</td>
</tr>


<tr>
<td class="org-left">C-c !</td>
<td class="org-left">&#x2026; but make timestamp inactive</td>
</tr>


<tr>
<td class="org-left">C-c C-d</td>
<td class="org-left">insert DEADLINE timestamp</td>
</tr>


<tr>
<td class="org-left">C-c C-s</td>
<td class="org-left">insert SCHEDULED timestamp</td>
</tr>


<tr>
<td class="org-left">C-c / d</td>
<td class="org-left">create sparse tree with all deadlines due</td>
</tr>


<tr>
<td class="org-left">C-c C-y</td>
<td class="org-left">the time between 2 dates in a time range</td>
</tr>


<tr>
<td class="org-left">S-RIGHT/LEFT</td>
<td class="org-left">change timestamp at point +/- one day [2]</td>
</tr>


<tr>
<td class="org-left">S-UP/DOWN</td>
<td class="org-left">change year/month/day at point +/- one unit [2]</td>
</tr>


<tr>
<td class="org-left">C-c ></td>
<td class="org-left">access calendar for the current date</td>
</tr>


<tr>
<td class="org-left">C-c <</td>
<td class="org-left">insert timestamp matching date in calendar</td>
</tr>


<tr>
<td class="org-left">C-c C-o</td>
<td class="org-left">access agenda for current date</td>
</tr>


<tr>
<td class="org-left">RET/mouse-1</td>
<td class="org-left">select date while prompted</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-t</td>
<td class="org-left">toggle custom format display for dates/time</td>
</tr>
</tbody>
</table>


<a id="org1215a20"></a>

### Clocking Time

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-x C-i</td>
<td class="org-left">start clock on current item</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-o/x</td>
<td class="org-left">stop/cancel clock on current item</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-d</td>
<td class="org-left">display total subtree times</td>
</tr>


<tr>
<td class="org-left">C-c C-c</td>
<td class="org-left">remove displayed times</td>
</tr>


<tr>
<td class="org-left">C-c C-x C-r</td>
<td class="org-left">insert/update table with clock report</td>
</tr>
</tbody>
</table>


<a id="org77f7bbb"></a>

## Agenda Views

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">usage</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c [</td>
<td class="org-left">add/move current file to front of agenda</td>
</tr>


<tr>
<td class="org-left">C-c ]</td>
<td class="org-left">remove current file from your agenda</td>
</tr>


<tr>
<td class="org-left">C-'</td>
<td class="org-left">cycle through agenda file list</td>
</tr>


<tr>
<td class="org-left">C-c C-x </></td>
<td class="org-left">set/remove restriction lock</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">C-c a a</td>
<td class="org-left">compile agenda for the current week [1]</td>
</tr>


<tr>
<td class="org-left">C-c a t</td>
<td class="org-left">compile global TODO list [1]</td>
</tr>


<tr>
<td class="org-left">C-c a T</td>
<td class="org-left">compile TODO list for keyword [1]</td>
</tr>


<tr>
<td class="org-left">C-c a m</td>
<td class="org-left">match tags, TODO keywords, properties [1]</td>
</tr>


<tr>
<td class="org-left">C-c a M</td>
<td class="org-left">match only TODO items [1]</td>
</tr>


<tr>
<td class="org-left">C-c a #</td>
<td class="org-left">find stuck projects [1]</td>
</tr>


<tr>
<td class="org-left">C-c a L</td>
<td class="org-left">show timeline of current org file [1]</td>
</tr>


<tr>
<td class="org-left">C-c a C</td>
<td class="org-left">configure custom commands [1]</td>
</tr>


<tr>
<td class="org-left">C-c C-o</td>
<td class="org-left">agenda for date at cursor</td>
</tr>
</tbody>
</table>


<a id="orga5465bc"></a>

# Register key bindings

recall registers are named: [a-z][A-Z][0-9], denoted as R in the keybindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-x r <SPC> R</td>
<td class="org-left">record position of point and the current buffer in R</td>
</tr>


<tr>
<td class="org-left">C-x r j R</td>
<td class="org-left">jump to the position and buffer saved in R</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">C-x r s R</td>
<td class="org-left">copy region into R</td>
</tr>


<tr>
<td class="org-left">C-u C-x r s R</td>
<td class="org-left">copy region into R; then delete it from buffer</td>
</tr>


<tr>
<td class="org-left">C-x r i R</td>
<td class="org-left">insert text from region R</td>
</tr>


<tr>
<td class="org-left">M-x append-to-register</td>
<td class="org-left">append region to text in register R; with prefix delete from buffer</td>
</tr>


<tr>
<td class="org-left">M-x prepend-to-register</td>
<td class="org-left">prepend</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">C-x r r R</td>
<td class="org-left">copy region into register</td>
</tr>


<tr>
<td class="org-left">C-x r i R</td>
<td class="org-left">insert rectangle</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">C-x r w R</td>
<td class="org-left">save the state of selected frames windows to R</td>
</tr>


<tr>
<td class="org-left">C-x r f R</td>
<td class="org-left">save the state of all frames</td>
</tr>


<tr>
<td class="org-left">C-x r j R</td>
<td class="org-left">restore window or frame positions; same as position</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">C-x r n R</td>
<td class="org-left">store 0 in register</td>
</tr>


<tr>
<td class="org-left">C-u NUMBER C-x r n R</td>
<td class="org-left">store NUMBER in register</td>
</tr>


<tr>
<td class="org-left">C-x r + R</td>
<td class="org-left">increment by 1</td>
</tr>


<tr>
<td class="org-left">C-u NUMBER C-x r + R</td>
<td class="org-left">if R contains a number, increment by NUMBER</td>
</tr>


<tr>
<td class="org-left">C-x r i R</td>
<td class="org-left">insert the number</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">C-x C-k x R</td>
<td class="org-left">store last keyboard macro in register</td>
</tr>


<tr>
<td class="org-left">C-x r j R</td>
<td class="org-left">execute the keyboard macro</td>
</tr>
</tbody>
</table>


<a id="org38d7583"></a>

# Bookmark key bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key binding</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-x r l</td>
<td class="org-left">list available bookmarks</td>
</tr>


<tr>
<td class="org-left">C-x r m</td>
<td class="org-left">set a bookmark</td>
</tr>


<tr>
<td class="org-left">C-x r b</td>
<td class="org-left">jump to a bookmark</td>
</tr>
</tbody>
</table>


<a id="org79f096a"></a>

# Company bindings


<a id="org7f9aeca"></a>

## While completing

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">M-n/p</td>
<td class="org-left">next/prev in completion list</td>
</tr>


<tr>
<td class="org-left">C-s C-r C-o</td>
<td class="org-left">search in completions</td>
</tr>


<tr>
<td class="org-left">M-(digit)</td>
<td class="org-left">pick the nth item in list</td>
</tr>
</tbody>
</table>


<a id="orgb37a4e3"></a>

## When a completion is selected

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left"><f1></td>
<td class="org-left">display docs</td>
</tr>


<tr>
<td class="org-left">C-w</td>
<td class="org-left">see source of completed item</td>
</tr>
</tbody>
</table>


<a id="org9a8ac98"></a>

# Clojure / CIDER key bindings


<a id="org12c39be"></a>

## Clojure key bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key binding</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c M-n</td>
<td class="org-left">switch to namespace of current buffer</td>
</tr>


<tr>
<td class="org-left">C-x C-e</td>
<td class="org-left">eval expression preceding point</td>
</tr>


<tr>
<td class="org-left">C-c C-k</td>
<td class="org-left">compile current buffer</td>
</tr>


<tr>
<td class="org-left">C-c C-d C-d</td>
<td class="org-left">display docs for symbol under point</td>
</tr>


<tr>
<td class="org-left">M-. and M-,</td>
<td class="org-left">jump/return to source for symbol under point</td>
</tr>


<tr>
<td class="org-left">C-c C-d C-a</td>
<td class="org-left">apropos search over func names and docs</td>
</tr>
</tbody>
</table>


<a id="org17fb2ba"></a>

## CIDER key bindings

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key binding</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">M-n, M-p</td>
<td class="org-left">cycle through repl history</td>
</tr>


<tr>
<td class="org-left">C-<ret></td>
<td class="org-left">close parentheses and eval</td>
</tr>
</tbody>
</table>


<a id="orgba10ae6"></a>

# Outline key bindings

-   outline minor mode (not used in org mode) uses prefix \`C-c @\`


<a id="orgecef7f8"></a>

## Outline Motion

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">used for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-n</td>
<td class="org-left">move point to next visible heading line</td>
</tr>


<tr>
<td class="org-left">C-c C-p</td>
<td class="org-left">&#x2026; previous &#x2026;</td>
</tr>


<tr>
<td class="org-left">C-c C-f</td>
<td class="org-left">move point to next visibile heading line at the same level</td>
</tr>


<tr>
<td class="org-left">C-c C-b</td>
<td class="org-left">&#x2026; previous &#x2026;</td>
</tr>


<tr>
<td class="org-left">C-c C-u</td>
<td class="org-left">move point to a lower-level (bigger, more inclusive) visible heading line</td>
</tr>
</tbody>
</table>


<a id="org9cc018a"></a>

## Outline Visibility

-   the outline visibility commands are superceded in org mode by TAB cycling.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">key</th>
<th scope="col" class="org-left">used for</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">C-c C-c</td>
<td class="org-left">make current heading line invisibile  (not in org mode; use TAB)</td>
</tr>


<tr>
<td class="org-left">C-c C-e</td>
<td class="org-left">&#x2026; visible (not in org mode; use TAB)</td>
</tr>


<tr>
<td class="org-left">&#x2026;</td>
<td class="org-left">many others that are not terribly releveant in org mode</td>
</tr>
</tbody>
</table>
