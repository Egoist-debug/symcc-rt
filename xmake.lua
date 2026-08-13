function add_runtime_sources()
    add_cxxflags("-Wredundant-decls", "-Wcast-align", "-Wmissing-include-dirs", "-Wswitch-default", 
                 "-Wextra", "-Wall", "-Winvalid-pch", "-Wredundant-decls", "-Wformat=2", 
                 "-Wmissing-format-attribute", "-Wformat-nonliteral")
    
    add_includedirs("include")
    add_files("src/Config.cpp", "src/RuntimeCommon.cpp", "src/LibcWrappers.cpp", "src/Shadow.cpp", "src/GarbageCollection.cpp")
    
    if get_config("backend") == "qsym" then
        local llvm_prefix = get_config("symcc_llvm_prefix")
        local llvm_major = tonumber(get_config("symcc_llvm_major"))
        add_files("src/backends/qsym/Runtime.cpp")
        local qsym_dir = "src/backends/qsym/qsym/qsym/pintool"
        add_includedirs("src/backends/qsym")
        add_includedirs(qsym_dir)
        add_files(path.join(qsym_dir, "expr.cpp"))
        add_files(path.join(qsym_dir, "expr_builder.cpp"))
        add_files(path.join(qsym_dir, "expr_cache.cpp"))
        add_files(path.join(qsym_dir, "expr_evaluate.cpp"))
        add_files(path.join(qsym_dir, "solver.cpp"))
        add_files(path.join(qsym_dir, "dependency.cpp"))
        add_files(path.join(qsym_dir, "logging.cpp"))
        add_files(path.join(qsym_dir, "afl_trace_map.cpp"))
        add_files(path.join(qsym_dir, "allocation.cpp"))
        add_files(path.join(qsym_dir, "call_stack_manager.cpp"))
        add_files(path.join(qsym_dir, "third_party/llvm/range.cpp"))
        add_files(path.join(qsym_dir, "third_party/xxhash/xxhash.cpp"))
        
        add_packages("z3")
        add_packages("llvm")
        add_linkdirs(path.join(llvm_prefix, "lib"))
        add_links("LLVM-" .. tostring(llvm_major))

        -- Qsym needs position independent code
        add_cxflags("-fPIC")
        
    elseif get_config("backend") == "simple" then
        add_files("src/backends/simple/Runtime.cpp")
        add_includedirs("src/backends/simple")
        add_packages("z3")
        add_cxflags("-fPIC")
    end
end

target("SymCCRuntime_static")
    set_kind("static")
    set_languages("c++17")
    set_basename("symcc-rt")
    add_runtime_sources()

target("SymCCRuntime_shared")
    set_kind("shared")
    set_languages("c++17")
    set_basename("symcc-rt")
    add_runtime_sources()

if has_config("target_32bit") then
    target("SymCCRuntime32_static")
        set_kind("static")
        set_languages("c++17")
        set_basename("symcc-rt")
        set_targetdir("$(buildir)/runtime32")
        add_cxflags("-m32")
        add_ldflags("-m32")
        add_runtime_sources()
        
    target("SymCCRuntime32_shared")
        set_kind("shared")
        set_languages("c++17")
        set_basename("symcc-rt")
        set_targetdir("$(buildir)/runtime32")
        add_cxflags("-m32")
        add_ldflags("-m32")
        add_runtime_sources()
end
