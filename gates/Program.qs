namespace gates {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;

    operation SetToOne(target: Qubit): Unit {
        SetQubitState(One, target);
    }

    operation SetToZero(target: Qubit): Unit {
        SetQubitState(Zero, target);
    }

    operation ApplyRotation(target: Qubit): Unit {
        SetQubitState(Zero, target);
        R(PauliX, 1.0, target);
    }

    operation SetQubitState(desired : Result, target : Qubit) : Unit {
        if (desired != M(target)) {
            X(target);
        }
    }

    operation RunTest(count : Int, test: (Qubit => Unit)) : Int {
        mutable numOnes = 0;
        using (qubit = Qubit()) {

            for (i in 1..count) {
                test(qubit);
                let res = M(qubit);

                if (res == One) {
                    set numOnes += 1;
                }
            }

            SetQubitState(Zero, qubit);
        }
        return numOnes;
    }

    operation TestGate(testName: String, count : Int, op : (Qubit => Unit)) : Unit {
        let numOnes = RunTest(count, op);
        // Return number of times we saw a |0> and number of times we saw a |1>
        Message(testName + ": Test results (# of 0s, # of 1s): " + IntAsString(count - numOnes) + ", " + IntAsString(numOnes));
    }

    @EntryPoint()
    operation RunTests(): Unit {
        let count = 1000;
        TestGate("SetToOne", count, SetToOne);
        TestGate("SetToZero", count, SetToZero);
        TestGate("Hadamard", count, H);
        TestGate("Rotate", count, ApplyRotation);
    }
}
