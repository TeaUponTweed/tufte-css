function Pandoc(doc)
    local article = pandoc.Div({}, {class = "article"})  -- Container for the entire document
    local section = nil  -- Current section, starts as nil
    local title_set = false
    local title = nil

    for _, block in ipairs(doc.blocks) do
        if block.t == "Header" and block.level == 1 then
            if not title_set then
                title = pandoc.utils.stringify(block)
                title_set = true
                -- This block is used as the document title, not added to content
                print("Set document title: " .. title)
            else
                -- Add subsequent level 1 headers directly to the article if no open section
                if not section then
                    article.content:insert(block)
                else
                    section.content:insert(block)
                end
            end
        elseif block.t == "Header" and block.level == 2 then
            if section then
                -- Close previous section by adding it to the article
                article.content:insert(section)
                print("Added section to article")
            end
            -- Start a new section with the level 2 header
            section = pandoc.Div({block}, {class = "section"})
            print("Started new section with header: " .. pandoc.utils.stringify(block))
        else
            if not section then
                -- Before any section starts, add blocks directly to the article
                article.content:insert(block)
                print("Added block directly to article")
            else
                -- Add block to the open section
                section.content:insert(block)
            end
        end
    end

    -- If there's an open section at the end, add it to the article
    if section then
        article.content:insert(section)
        print("Added final section to article")
    end

    -- Update document metadata if a title was set
    if title then
        doc.meta.pagetitle = pandoc.MetaString(title)
    end

    -- Return the complete document
    return pandoc.Pandoc(article, doc.meta)
end
