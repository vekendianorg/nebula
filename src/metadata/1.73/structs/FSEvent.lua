--==================================================
-- metadata/1.73/FSEvent.lua
--==================================================
-- FSEvent (event-handler list) snapshot — used as the shared
-- element template for every FSEvent-typed field in PlayerInfo and
-- RaceInfo.
--
-- Dump basis: FSEvent_200D3F54 // TypeDefIndex 1199, Size 0x30,
-- Confidence: exact — a C++/CLI mangled FSEvent<T> instantiation
-- with fields mHandlers (List<FSEvent>, 0x0) and
-- mConditionalHandlers (List<FSEvent>, 0x18). Every explicit
-- FSEvent_<...> instantiation in the dump is Size 0x30 with
-- exactly these two fields; the parameterless FSEvent<T>
-- instantiations PlayerInfo/RaceInfo embed resolve to the same
-- erased layout, so this one class metadata file serves them all.
-- One class definition per file — this file is that class only.
-- (Previously named FSEvent_200D3F54.lua after one mangled
-- instantiation; the suffix is a hash, not a reliable offset, so
-- the file is named for the erased class instead.)
--
-- The std::vector<List<...>> internals are intentionally NOT
-- metadata: List<T> has no supported representation (see
-- PlayerInfo.lua header note). The offsets below still record the
-- exact dump layout.
-- Metadata keys are camelCase: leading `m` stripped, next character
-- lowercased (mHandlers -> handlers).
return {
    ["handlers"] = {
        -- dump: List<FSEvent> mHandlers // 0x0
        offset = 0x0,
        type = "Array"
    },  -- List<FSEvent> (vector header, element type unmapped)
    ["conditionalHandlers"] = {
        -- dump: List<FSEvent> mConditionalHandlers // 0x18
        offset = 0x18,
        type = "Array"
    },  -- List<FSEvent> (vector header, element type unmapped)
}
