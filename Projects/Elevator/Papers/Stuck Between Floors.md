# Stuck Between Floors: How Elevator Algorithms Make Us Wait… and Wait… and Wait
by Shrutika Poyrekar

Original article on [medium](https://medium.com/@mumbaiyachori/stuck-between-floors-how-elevator-algorithms-make-us-wait-and-wait-and-wait-b29e7e4bf728)

After years of chasing data and dissecting algorithms that power everything from fraud detection to machine learning, I never expected my biggest frustration with technology would come from something as old-school as an **elevator**. But here we are, living the dream on the 60th floor of one of the tallest buildings in Abu Dhabi, staring out at the sea — just as I imagined as a kid growing up in Mumbai. The view? Spectacular. The reality? Less so, especially when getting up and down the building.

Now, do not get me wrong. I have worked with complex models that make neural networks seem like child’s play. But elevators? They take the cake. Six shiny, large machines split across floors 1–32 and 33–60, and yet, despite all the apparent engineering marvels, I’m stuck waiting for them every day. With all our technological advancements, it's as if we’ve somehow forgotten how to move people efficiently between floors.

Let me paint you a picture. You are waiting on **G** (Ground Floor), innocently pressing the button to head to the 60th floor. An elevator comes zipping up from the basement, packed with people — **every last spot filled**. It stops at G, the doors open, and I stand there, admiring the nice people squashed inside like sardines, knowing full well that **not a single person** is getting out to let me in. The doors close. The elevator takes off. And there I am, left on the ground like a character in a cruel existential play, pressing the button all over again.

Why does it stop if it is full? Why am I forced into this dance of futility? I have spent my career optimizing systems, and it boggles the mind that an **elevator algorithm** — yes, an actual algorithm — could be this poorly optimized. This is where my inner CS grad kicks in. How do these elevator algorithms work, and why are they failing me so remarkably 

# How Elevators “Think” — The Basics of the Elevator Algorithm
Let us peel back the curtain and take a look at how elevators operate — or, more specifically, how they do not operate as well as they could.

Elevators follow a scheduling algorithm that is pretty much similar to the **SCAN algorithm** used in disk scheduling. For those unfamiliar with the SCAN algorithm, it works like this- the system moves in one direction, serving requests as it goes until it hits the last request in that direction. It then **reverses**, moving back the other way and servicing more requests on its return trip. Much like an elevator, SCAN minimizes the time wasted switching between directions.

Let me break it down in code:

```python
def elevatorScan(requests, currentFloor, direction="up"):
    """
    Basic SCAN (elevator) algorithm.
    requests: A list of floor requests to be serviced.
    currentFloor: The current position of the elevator.
    direction: The direction the elevator is moving ("up" or "down").
    """
    while requests:
        # Sort requests depending on the direction of travel—elevators love predictable routines.
        if direction == "up":
            requests.sort()
        else:
            requests.sort(reverse=True)

        for request in requests:
            if (direction == "up" and request >= currentFloor) or \
               (direction == "down" and request <= currentFloor):
                print(f"Stopping at floor {request}")
                currentFloor = request
                requests.remove(request)
                
        # Change direction once you've hit the last floor, because elevators don’t believe in circular movement.
        direction = "down" if direction == "up" else "up"

```
In theory, this is simple and efficient. The elevator, much like a disk head, only changes direction when it reaches the last stop in its current path. This prevents it from zigzagging between floors or tracks unnecessarily. So far, so good, right?

# The Problem? Coordination, or the Lack Thereof
This only works for one elevator and it does not account for capacity. In reality, I have three elevators servicing my floor, and here’s where things get messy. You’d expect the elevators to coordinate, right? **Nope**. They behave like competitors, with each one oblivious to what the others are doing. The closest elevator might come to my floor — even if it’s full — while the others sit there, perfectly capable of taking me up, but not budging.

# Multiple Elevators, No Coordination
So, let us simulate this for **multiple elevators**. Each elevator has its own SCAN-like algorithm, but there’s no sharing of information between them. This leads to inefficiency, where the elevator closest to you might be full, but instead of dispatching another elevator, you’re left waiting as if the system is punishing you for trying to get to work.

Here is what a multiple elevator system without capacity awareness looks like:

```python
def multipleElevators(elevators, requests):
    """
    Simulate multiple elevators, each with their own SCAN algorithm.
    elevators: A dictionary where keys are elevator IDs and values are dictionaries with their current state.
    requests: A list of floor requests to be serviced.
    """
    while requests:
        for elevatorId, elevator in elevators.items():
            # Check if this elevator is moving in the right direction—because coordination is too much to ask for.
            if elevator['direction'] == 'up':
                directionRequests = [r for r in requests if r >= elevator['currentFloor']]
                direction = "up"
            else:
                directionRequests = [r for r in requests if r <= elevator['currentFloor']]
                direction = "down"
            
            if directionRequests:
                # Move elevator based on requests and capacity, as if capacity isn't already a problem.
                nextFloor = min(directionRequests) if direction == "up" else max(directionRequests)
                if elevator['capacity'] < elevator['maxCapacity']:
                    print(f"Elevator {elevatorId} stopping at floor {nextFloor}")
                    elevator['currentFloor'] = nextFloor
                    elevator['capacity'] += 1  # Simulate passengers boarding
                    requests.remove(nextFloor)
                else:
                    print(f"Elevator {elevatorId} is full! Skipping stop at floor {nextFloor}")
            
            # Reverse direction if no more requests in that direction—who needs teamwork anyway?
            if not directionRequests:
                elevator['direction'] = "down" if elevator['direction'] == "up" else "up"

elevators = {
    'Elevator 1': {'currentFloor': 10, 'direction': 'up', 'capacity': 5, 'maxCapacity': 10},
    'Elevator 2': {'currentFloor': 20, 'direction': 'down', 'capacity': 3, 'maxCapacity': 10},
    'Elevator 3': {'currentFloor': 30, 'direction': 'up', 'capacity': 8, 'maxCapacity': 10},
}
requests = [5, 25, 40, 50, 60]

multipleElevators(elevators, requests)
```

# The Problem: Capacity Awareness Missing
In this version, the nearest elevator may stop at your floor, **even if it’s full**. As someone stranded on G, this is maddening. The algorithm is direction-aware, but not capacity-aware. Here’s the fix: introduce **capacity constraints** and ensure that if the nearest elevator is full, another one will come instead.

# The Solution: Capacity-Aware Coordinated Elevators
Now, let us improve this system by introducing **capacity awareness** and coordination between elevators. If the closest elevator is full, we’ll ensure that the next closest available one is dispatched. This involves checking the capacity of each elevator before dispatching it, and if one is full, another elevator will step in to take its place.

Here is the updated code with **capacity checks** and coordination:

```python
def coordinatedElevatorsWithCapacity(elevators, requests):
    """
    Simulate coordinated elevators with capacity awareness, where they communicate to balance load.
    elevators: A dictionary of elevators with their current state.
    requests: A list of floor requests to be serviced.
    """
    while requests:
        for request in requests:
            closestElevator = None
            minDistance = float('inf')
            
            # Check for the closest elevator that has capacity—because apparently that's a new idea.
            for elevatorId, elevator in elevators.items():
                distance = abs(elevator['currentFloor'] - request)
                if distance < minDistance and elevator['capacity'] < elevator['maxCapacity']:
                    closestElevator = elevatorId
                    minDistance = distance
            
            if closestElevator:
                # Assign the closest elevator with capacity to handle the request.
                elevator = elevators[closestElevator]
                print(f"Elevator {closestElevator} moving to floor {request}")
                elevator['currentFloor'] = request
                elevator['capacity'] += 1  # Simulate passengers boarding
                requests.remove(request)
            else:
                # If all elevators are full, no one can service the request—fun times ahead.
                print(f"All elevators full! No available elevator for floor {request}")
        
        # Reset capacity for the next loop after all requests are processed
        for elevatorId, elevator in elevators.items():
            elevator['capacity'] = 0  # Reset capacity after servicing the requests

```

# Why This Fixes the Problem
With this improvement, you’re no longer at the mercy of a **single full elevator**. The system is now **aware of capacity** and will dispatch an elevator that actually has room for you. No more watching a full elevator stop at G, taunting you with its empty promises. Now, if one elevator is full, the next one takes over — efficient, right?

# The Future of Smarter Elevators
We’re getting closer to what an optimized elevator system should look like- multiple elevators coordinating their movements, checking each other’s capacities, and ensuring that no one gets left behind (unless, of course, they’re really, really late).

Until then, I’ll be here on the 60th floor, waiting for my ride — knowing that at least now, I’ve built an algorithm that actually cares about my time. Even though it is not live. Ahh, just another algorithm to add to my ever-growing list of models that never saw the light of day.

