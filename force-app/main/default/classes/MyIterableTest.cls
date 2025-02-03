@IsTest
public class MyIterableTest {
    @IsTest
    static void testIterableForLoop() {
        // Create a list of strings
        List<String> strings = new List<String>{ 'Hello', 'World' };

        // Create an instance of MyIterable
        MyIterable iterable = new MyIterable(strings);
  
        // Use a for loop to iterate over the iterable
        for (String str : iterable) {

            System.debug('str'+str);
        } 
        // Assertions (Optional: Verify the contents programmatically)
        List<String> expected = new List<String>{ 'Hello', 'World' };
        List<String> result = new List<String>(); 
        for (String str : iterable) {
            result.add(str);
        }
        System.assertEquals(expected, result, 'The iterable output does not match the expected values.');
    }
}