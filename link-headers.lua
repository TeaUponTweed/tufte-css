function Header(elem)
  -- Only create links if the header has an ID
  if elem.identifier ~= "" then
    -- Create a link that targets the header's own ID
    local link = pandoc.Link(elem.content, '#' .. elem.identifier, '', {})
    -- Replace the header's content with this link
    elem.content = { link }
  end
  return elem
end
