-- Import the necessary Pandoc modules
local List = require 'pandoc.List'
local stringify = require 'pandoc.utils'.stringify

-- Helper function to determine the note type and adjust content
local function adjustNoteContent(blocks)
  local firstBlock = blocks[1]
  if firstBlock then
    local firstInline = firstBlock.content[1]
    if firstInline and firstInline.t == 'Str' then
      if firstInline.text == "{-}" then
        -- Margin note
        table.remove(firstBlock.content, 1)
        table.remove(firstBlock.content, 1) -- remove the Space
        return 'MarginNote', blocks
      elseif firstInline.text == "{.}" then
        -- Footnote
        table.remove(firstBlock.content, 1)
        table.remove(firstBlock.content, 1) -- remove the Space
        return 'FootNote', blocks
      end
    end
  end
  -- Default to SideNote if no special marker
  return 'SideNote', blocks
end

-- Inline to HTML conversion with unique identifier
function inlineToHTML(id, content, isMarginNote)
  local noteClass = isMarginNote and "marginnote" or "sidenote"
  local label = string.format('<label for="sn-%d" class="margin-toggle%s"></label>', id, isMarginNote and "" or " sidenote-number")
  local input = string.format('<input type="checkbox" id="sn-%d" class="margin-toggle"/>', id)
  local note = string.format('<span class="%s">%s</span>', noteClass, stringify(content))

  return pandoc.RawInline('html', label .. input .. note)
end

-- State counter for unique sidenote IDs
local noteId = 0

-- Convert notes to side/margin notes
function Note(elem)
  noteId = noteId + 1
  local noteType, blocks = adjustNoteContent(elem.content)
  local content = pandoc.walk_block(pandoc.Div(blocks), {
    Str = function(el) return pandoc.Str(stringify(el)) end,
    Space = function(el) return pandoc.Space() end,
  })

  if noteType == 'FootNote' then
    return pandoc.Note(blocks)
  else
    return inlineToHTML(noteId, content, noteType == 'MarginNote')
  end
end

-- Apply transformations to the document
return {
  { Pandoc = function(doc)
      return pandoc.walk_block(pandoc.Pandoc(doc.blocks, doc.meta), {Note = Note})
    end
  }
}

