def test_p2():
    from repro_p1 import test

    print("Hello from p2")
    test.test_p1()


def test_p2_against_changed_p1():
    from repro_p1 import test2

    test2.test2_p1()


if __name__ == "__main__":
    test_p2()
