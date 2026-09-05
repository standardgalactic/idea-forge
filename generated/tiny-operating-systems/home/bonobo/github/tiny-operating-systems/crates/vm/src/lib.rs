use core_kernel::boot_banner;

pub fn describe() -> String {
    format!("workspace member uses {}", boot_banner())
}
