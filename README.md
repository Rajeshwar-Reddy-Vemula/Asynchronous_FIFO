An asynchronous FIFO (First-In-First-Out) system is designed to handle data transfer between different clock domains, ensuring correct data transmission even when the input and output devices operate at different clock speeds. The design typically involves a memory array, write pointer, and read pointer, each managed in separate clock domains to prevent timing issues and ensure data integrity.

In an asynchronous FIFO, the write pointer always points to the next word to be written, while the read pointer always points to the current FIFO word to be read. This setup allows the receiver logic to read data without multiple clock periods to fetch the data word.

Use of Gray code and then compare the pointers MSB bit to check the condition

On reset, both write and read pointers are set to zero

After writing the to the memory location that is pointed, write pointer will be incremented to point next location

After reading from the memory location that is pointed, read pointer will be incremented to point next location


