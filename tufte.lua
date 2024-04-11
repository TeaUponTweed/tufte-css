function Pandoc(doc)
    local blocks = pandoc.List()  -- Store the new blocks in a list
    local article = pandoc.Div({}, {class = "article"})  -- Create an article div initialized with an empty list
    local section = pandoc.Div({}, {class = "section"})  -- Create a section div initialized with an empty list
    local in_section = false  -- Track if we are currently wrapping in a section
    local title_set = false
    local title = nil

    for _, block in ipairs(doc.blocks) do
        if block.t == "Header" and block.level == 1 then
            if not title_set then
                title = pandoc.utils.stringify(block)
                title_set = true
                -- Skip the first level 1 header block to not add it to the article content
            else
                -- If it's another level 1 header, add it normally
                article.content:extend({block})
            end
        elseif block.t == "Header" and block.level == 2 then
            print('header 2')
            -- Finish the previous section if it exists and start a new one
            if in_section then
                print('new section')
                article.content:extend({section})  -- Add the finished section to the article
                section = pandoc.Div({}, {class = "section"})  -- Reset the section
            end
            print('weird, this will overwrite section')
            section = pandoc.Div({block}, {class = "section"})  -- Start a new section with the header
            in_section = true  -- Mark that we are in a section
        else
            -- Add block to the current section if inside a section; otherwise, add to the article directly
            if in_section then
                section.content:extend({block})
            else
                article.content:extend({block})
            end
        end
    end

    -- Add the last open section if any
    if in_section then
        article.content:extend({section})
    end

    -- Add the complete article to the document's blocks
    blocks:extend({article})

    -- Set the document's page title from the first level 1 header if it was captured
    if title then
        doc.meta.pagetitle = pandoc.MetaString(title)
    end

    return pandoc.Pandoc(blocks, doc.meta)
end
