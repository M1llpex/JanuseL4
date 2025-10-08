# Add platform-specific sources to a variable
add_sources(
    PLAT_sources
    src/plat_entry.S
    src/hardware.c
    src/gic.c
    src/serial.c
    src/cache.c
    src/smp.c
)
target_include_directories(shiba INTERFACE include)

# Build the platform-specific library from the source list
add_library(shiba STATIC src/plat/shiba)
