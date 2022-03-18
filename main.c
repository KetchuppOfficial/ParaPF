extern void ParaPF (const char *, ...);

int main (void)
{
    ParaPF ("Hello, %x World!\n", 3802);
    
    return 0;
}
