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

-- Function to convert blocks to inlines
local function blocksToInlines(blocks)
    local inlines = List:new()
    for _, block in ipairs(blocks) do
        if block.t == 'Para' or block.t == 'Plain' then
            inlines:extend(block.content)
        elseif block.t == 'LineBlock' then
            for _, line in ipairs(block.content) do
                inlines:extend(line)
                inlines:insert(pandoc.LineBreak())
            end
        end
    end
    return inlines
end

-- Inline to HTML conversion with unique identifier
function inlineToHTML(id, inlines, isMarginNote)
  local noteClass = isMarginNote and "marginnote" or "sidenote"
  local label = string.format('<label for="sn-%d" class="margin-toggle%s"></label>', id, isMarginNote and "" or " sidenote-number")
  local input = string.format('<input type="checkbox" id="sn-%d" class="margin-toggle"/>', id)
  local note = string.format('<span class="%s">%s</span>', noteClass, stringify(inlines))

  return pandoc.RawInline('html', label .. input .. note)
end

-- State counter for unique sidenote IDs
local noteId = 0

-- Convert notes to side/margin notes
function Note(elem)
  noteId = noteId + 1
  local noteType, blocks = adjustNoteContent(elem.content)
  local inlines = blocksToInlines(blocks)

  if noteType == 'FootNote' then
    return pandoc.Note(blocks)
  else
    return inlineToHTML(noteId, inlines, noteType == 'MarginNote')
  end
end

-- Apply transformations to the document
return {
  { Pandoc = function(doc)
      local blocks = pandoc.walk_block(pandoc.Div(doc.blocks), {Note = Note}).content
      return pandoc.Pandoc(blocks, doc.meta)
    end
  }
}
