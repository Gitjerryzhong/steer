package cn.edu.bnuz.steer


import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
@TestFor(ObservationFormInterceptor)
class ObservationFormInterceptorSpec extends Specification {

    def setup() {
    }

    def cleanup() {

    }

    void "Test supervisorForm interceptor matching"() {
        when:"A request matches the interceptor"
            withRequest(controller:"observationForm")

        then:"The interceptor does match"
            interceptor.doesMatch()
    }
}
