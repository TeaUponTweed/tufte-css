function Pandoc(doc)
    local blocks = pandoc.List()  -- Store the new blocks in a list
    local article = pandoc.Div({}, {class = "article"})  -- Create an article div initialized with an empty list
    -- local section = pandoc.Div({}, {class = "section"})  -- Create a section div initialized with an empty list
    local section = nil
    local title_set = false
    local title = nil
    -- local p = pandoc.Para({pandoc.Str("Hello World")})

    for _, block in ipairs(doc.blocks) do
        if block.t == "Header" and block.level == 1 then
            if not title_set then
                title = pandoc.utils.stringify(block)
                title_set = true
                print("set title to: " .. title)
                -- Skip the first level 1 header block to not add it to the article content
            else
                -- If it's another level 1 header, add it normally
                print("addinging H1 block directly to article")
                article.content:insert(block)
            end
        elseif block.t == "Header" and block.level == 2 then
            -- Finish the previous section if it exists and start a new one
            if section then
                print("adding section to article")
                article.content:insert(section)  -- Add the finished section to the article
                section = nil
            end
            print("adding new section header to article")
            section = pandoc.Div({}, {class = "section"})  -- Start a new section with the header
            section.content:insert(block)
        else
            -- Add block to the current section if inside a section; otherwise, add to the article directly
            if section then
                -- print("adding block to section")
                section.content:insert(block)
            else
                print("adding block directly to article")
                article.content:insert(block)
            end
        end
    end

    -- Add the last open section if any
    if section then
        print("inserting final section")
        article.content:insert(section)
    end

    -- Set the document's page title from the first level 1 header if it was captured
    if title then
        doc.meta.pagetitle = pandoc.MetaString(title)
    end

    return pandoc.Pandoc(article, doc.meta)
end
