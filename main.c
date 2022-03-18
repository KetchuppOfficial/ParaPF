extern void ParaPF (const char *, ...);

int main (void)
{
    ParaPF ("Hi, stranger!\n");
    ParaPF ("You are lucky to run into me: ParaPF\n");
    ParaPF ("ParaPF is the %X%XTT%XR then printf (no doubt)\n\n", 11, 14, 14);
    ParaPF ("I can no longer hide this from everyone...\n");
    ParaPF ("...\n");
    ParaPF ("%c %s %d is %b, %o and even %x, and I %s %X %d %% %c%b\n", 'I', "exactly know that", 3802, 3802, 3802, 3802, "love", 3802, 100, 33, 127);
    ParaPF ("With best regards!\n");
    
    return 0;
}
