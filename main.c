extern void ParaPF (const char *, ...);

int main (void)
{
    ParaPF ("Hello, %d World!\n", 123);
    
    return 0;
}
