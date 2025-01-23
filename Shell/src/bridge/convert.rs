pub mod sen {

    pub mod shell {

        use crate::bridge::data::sen::shell::{CStringList, CStringView};

        use libc;
        use libc::malloc;

        pub unsafe fn to_cstring(
            source: &String, 
            destination: *mut CStringView
        ) {
            let value: *mut u8 = malloc(source.len() + 1) as *mut u8;
            std::ptr::copy_nonoverlapping(source.as_ptr(), value, source.len());
            // TODO : add null terminator
            //value[source.len()] = 0;
            (*destination).value = value;
            (*destination).size = source.len() as libc::size_t;
        }

        pub unsafe fn to_string_list(
            source: &Vec<String>, 
            destination: &mut CStringList
        ) {
            let value: *mut CStringView = malloc(source.len() as libc::size_t) as *mut CStringView;
            for index in 0..source.len() {
                let value: *mut CStringView = value.offset(index as isize);
                to_cstring(&source[index], value);
            }
            (*destination).value = value;
            (*destination).size = source.len() as libc::size_t;
        }

        pub unsafe fn to_string(
            source: *mut CStringView,
            destination: &mut String
        ) {
            let value: *mut u8 = (*source).value;
            let value: &str = std::str::from_utf8_unchecked(std::slice::from_raw_parts(value, (*source).size));
            *destination = value.to_string();
        }

        pub unsafe fn to_vector(
            source: *mut CStringList,
            destination: &mut Vec<String>
        ) {
            let size = (*source).size;
            destination.reserve(size);
            for index in 0..size {
                let mut value = String::new();
                let current = (*source).value.offset(index as isize);
                value.reserve((*current).size);
                to_string(current, &mut value);
                destination.push(value);
            }
        }

    }

}